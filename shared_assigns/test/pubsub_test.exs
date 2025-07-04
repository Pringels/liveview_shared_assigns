defmodule SharedAssigns.PubSubTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule TestPubSub do
    use GenServer

    def start_link(opts) do
      GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
    end

    def init(state), do: {:ok, state}

    def subscribe(pubsub, topic) when pubsub == __MODULE__ do
      Registry.register(TestPubSub.Registry, topic, nil)
    end

    def broadcast(pubsub, topic, message) when pubsub == __MODULE__ do
      Registry.dispatch(TestPubSub.Registry, topic, fn entries ->
        for {pid, _} <- entries, do: send(pid, message)
      end)

      :ok
    end

    def broadcast!(pubsub, topic, message) when pubsub == __MODULE__ do
      broadcast(pubsub, topic, message)
    end

    def local_broadcast(pubsub, topic, message) when pubsub == __MODULE__ do
      broadcast(pubsub, topic, message)
    end

    def local_broadcast!(pubsub, topic, message) when pubsub == __MODULE__ do
      broadcast(pubsub, topic, message)
    end

    def direct_broadcast(_node, pubsub, topic, message) when pubsub == __MODULE__ do
      broadcast(pubsub, topic, message)
    end

    def direct_broadcast!(_node, pubsub, topic, message) when pubsub == __MODULE__ do
      broadcast(pubsub, topic, message)
    end
  end

  defmodule TestPubSubProvider do
    use Phoenix.LiveView

    use SharedAssigns.PubSubProvider,
      contexts: [
        theme: "light",
        user_role: "admin"
      ],
      pubsub: SharedAssigns.PubSubTest.TestPubSub

    def render(assigns) do
      ~H"""
      <div>PubSub Provider Test</div>
      """
    end

    def handle_event("update_theme", %{"theme" => theme}, socket) do
      socket = put_context(socket, :theme, theme)
      {:noreply, socket}
    end

    def handle_event("update_role", %{"role" => role}, socket) do
      socket = put_context(socket, :user_role, role)
      {:noreply, socket}
    end
  end

  defmodule TestPubSubConsumer do
    use Phoenix.LiveView

    use SharedAssigns.PubSubConsumer,
      contexts: [:theme, :user_role],
      pubsub: SharedAssigns.PubSubTest.TestPubSub

    def render(assigns) do
      ~H"""
      <div>
        <span id="theme-value">{@theme}</span>
        <span id="role-value">{@user_role}</span>
      </div>
      """
    end
  end

  @endpoint SharedAssigns.TestEndpoint

  setup do
    start_supervised!({Registry, keys: :duplicate, name: TestPubSub.Registry})
    start_supervised!(TestPubSub)
    :ok
  end

  describe "PubSubProvider" do
    test "broadcasts context changes via PubSub" do
      {:ok, provider_view, _html} = live_isolated(build_conn(), TestPubSubProvider)

      # Subscribe to the PubSub topic manually to verify broadcasting
      TestPubSub.subscribe(TestPubSub, "shared_assigns:theme")

      # Update theme via the provider
      render_click(provider_view, "update_theme", %{"theme" => "dark"})

      # Verify we received the PubSub message
      assert_receive {:context_changed, :theme, "dark", 2}
    end

    test "provides helper functions for context management" do
      {:ok, provider_view, _html} = live_isolated(build_conn(), TestPubSubProvider)

      # Test put_context functionality
      render_click(provider_view, "update_theme", %{"theme" => "dark"})

      # Get the updated socket
      socket = :sys.get_state(provider_view.pid).socket

      # Check that context was updated and version incremented
      assert socket.assigns.__shared_assigns_contexts__.theme == "dark"
      assert socket.assigns.__shared_assigns_versions__.theme == 2
    end

    test "exposes PubSub module and context keys" do
      assert TestPubSubProvider.__shared_assigns_pubsub__() == TestPubSub

      keys = TestPubSubProvider.context_keys()
      assert :theme in keys
      assert :user_role in keys
      assert length(keys) == 2
    end
  end

  describe "PubSubConsumer" do
    test "subscribes to PubSub topics on mount" do
      # Start the consumer
      {:ok, consumer_view, _html} = live_isolated(build_conn(), TestPubSubConsumer)

      # Broadcast a context change
      TestPubSub.broadcast(TestPubSub, "shared_assigns:theme", {
        :context_changed,
        :theme,
        "dark",
        1
      })

      # Give the message time to be processed
      :timer.sleep(10)

      # Check that the consumer received and processed the message
      socket = :sys.get_state(consumer_view.pid).socket
      assert socket.assigns.theme == "dark"
      assert socket.assigns.__subscribed_context_versions__.theme == 1
    end

    test "only updates when version is newer" do
      {:ok, consumer_view, _html} = live_isolated(build_conn(), TestPubSubConsumer)

      # Send a newer version first
      TestPubSub.broadcast(TestPubSub, "shared_assigns:theme", {
        :context_changed,
        :theme,
        "dark",
        5
      })

      :timer.sleep(10)
      socket = :sys.get_state(consumer_view.pid).socket
      assert socket.assigns.theme == "dark"
      assert socket.assigns.__subscribed_context_versions__.theme == 5

      # Send an older version - should be ignored
      TestPubSub.broadcast(TestPubSub, "shared_assigns:theme", {
        :context_changed,
        :theme,
        "light",
        3
      })

      :timer.sleep(10)
      socket = :sys.get_state(consumer_view.pid).socket
      # Should still be "dark" with version 5
      assert socket.assigns.theme == "dark"
      assert socket.assigns.__subscribed_context_versions__.theme == 5
    end

    test "ignores contexts it doesn't subscribe to" do
      {:ok, consumer_view, _html} = live_isolated(build_conn(), TestPubSubConsumer)

      # Send a context change for a context we don't subscribe to
      TestPubSub.broadcast(TestPubSub, "shared_assigns:notifications", {
        :context_changed,
        :notifications,
        ["new message"],
        1
      })

      :timer.sleep(10)
      socket = :sys.get_state(consumer_view.pid).socket

      # Should not have notifications in assigns
      refute Map.has_key?(socket.assigns, :notifications)
    end
  end

  describe "PubSub integration" do
    test "provider and consumer work together" do
      # Start both provider and consumer
      {:ok, provider_view, _html} = live_isolated(build_conn(), TestPubSubProvider)
      {:ok, consumer_view, consumer_html} = live_isolated(build_conn(), TestPubSubConsumer)

      # Initially consumer should have nil values
      assert consumer_html =~ ~s(<span id="theme-value"></span>)
      assert consumer_html =~ ~s(<span id="role-value"></span>)

      # Update theme via provider
      render_click(provider_view, "update_theme", %{"theme" => "dark"})

      # Give PubSub time to deliver the message
      :timer.sleep(10)

      # Re-render consumer to see changes
      updated_html = render(consumer_view)
      assert updated_html =~ ~s(<span id="theme-value">dark</span>)

      # Update role via provider
      render_click(provider_view, "update_role", %{"role" => "guest"})

      :timer.sleep(10)

      # Re-render consumer again
      final_html = render(consumer_view)
      assert final_html =~ ~s(<span id="theme-value">dark</span>)
      assert final_html =~ ~s(<span id="role-value">guest</span>)
    end
  end

  defp build_conn do
    Phoenix.ConnTest.build_conn()
    |> Plug.Test.init_test_session(%{})
  end
end
