defmodule SharedAssigns.ProviderTest do
  use ExUnit.Case, async: true

  defmodule TestProvider do
    use Phoenix.LiveView

    use SharedAssigns.Provider,
      contexts: [
        theme: "light",
        user_role: "admin"
      ]

    def render(assigns) do
      ~H"""
      <div>Provider Test</div>
      """
    end

    def handle_event("update_theme", %{"theme" => theme}, socket) do
      socket = put_context(socket, :theme, theme)
      {:noreply, socket}
    end
  end

  defmodule TestConsumerComponent do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H"""
      <div id="test-consumer">
        Theme: <%= @theme %>
        Role: <%= @user_role %>
      </div>
      """
    end

    def update(assigns, socket) do
      {:ok, assign(socket, assigns)}
    end

    # Define which contexts this component subscribes to
    def subscribed_contexts, do: [:theme, :user_role]
  end

  describe "Provider macro" do
    test "initializes contexts properly" do
      # Test that the Provider macro sets up the expected contexts
      contexts = TestProvider.__shared_assigns_contexts__()
      assert Keyword.get(contexts, :theme) == "light"
      assert Keyword.get(contexts, :user_role) == "admin"
    end

    test "provides helper functions" do
      # Test that the Provider macro injects the expected functions
      assert function_exported?(TestProvider, :put_context, 3)
      assert function_exported?(TestProvider, :update_context, 3)
      assert function_exported?(TestProvider, :get_context, 2)
    end

    test "exposes context_keys function" do
      keys = TestProvider.context_keys()
      assert :theme in keys
      assert :user_role in keys
      assert length(keys) == 2
    end
  end

  describe "Provider macro mount behavior" do
    test "defines mount/3 with context initialization" do
      assert function_exported?(TestProvider, :mount, 3)

      # Create a basic socket structure for testing
      socket = %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        endpoint: nil,
        view: TestProvider,
        router: nil
      }

      # Test that mount initializes contexts
      {:ok, updated_socket} = TestProvider.mount(%{}, %{}, socket)

      assert Map.has_key?(updated_socket.assigns, :__shared_assigns_contexts__)
      assert Map.has_key?(updated_socket.assigns, :__shared_assigns_versions__)
    end
  end

  describe "Context management with explicit assigns" do
    setup do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        endpoint: nil,
        view: TestProvider,
        router: nil
      }

      {:ok, mounted_socket} = TestProvider.mount(%{}, %{}, socket)
      {:ok, socket: mounted_socket}
    end

    test "initializes contexts in socket assigns", %{socket: socket} do
      # Test that contexts are stored in assigns, not process dictionary
      assert socket.assigns[:__shared_assigns_contexts__][:theme] == "light"
      assert socket.assigns[:__shared_assigns_contexts__][:user_role] == "admin"

      # Ensure no process dictionary usage
      assert Process.get(:shared_assigns_contexts) == nil
    end

    test "put_context updates context in assigns", %{socket: socket} do
      updated_socket = TestProvider.put_context(socket, :theme, "dark")

      # Verify context is updated in assigns
      assert updated_socket.assigns[:__shared_assigns_contexts__][:theme] == "dark"
      assert updated_socket.assigns[:__shared_assigns_contexts__][:user_role] == "admin"

      # Verify version was incremented
      assert updated_socket.assigns[:__shared_assigns_versions__][:theme] >
               socket.assigns[:__shared_assigns_versions__][:theme]
    end

    test "get_context retrieves context from assigns", %{socket: socket} do
      assert TestProvider.get_context(socket, :theme) == "light"
      assert TestProvider.get_context(socket, :user_role) == "admin"
      assert TestProvider.get_context(socket, :nonexistent) == nil
    end

    test "update_context uses function to update context", %{socket: socket} do
      updated_socket =
        TestProvider.update_context(socket, :theme, fn current ->
          case current do
            "light" -> "dark"
            "dark" -> "light"
          end
        end)

      assert TestProvider.get_context(updated_socket, :theme) == "dark"
    end
  end

  describe "Explicit assigns injection via helpers" do
    test "sa_component helper injects context as assigns" do
      # This test verifies that the helper functions inject contexts as explicit assigns
      # The actual injection logic is tested in the helpers_test module, but we verify
      # that the Provider sets up the required infrastructure

      socket = %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        endpoint: nil,
        view: TestProvider,
        router: nil
      }

      {:ok, mounted_socket} = TestProvider.mount(%{}, %{}, socket)

      # Verify that contexts are available for injection
      contexts = mounted_socket.assigns[:__shared_assigns_contexts__]
      assert contexts[:theme] == "light"
      assert contexts[:user_role] == "admin"
    end
  end
end
