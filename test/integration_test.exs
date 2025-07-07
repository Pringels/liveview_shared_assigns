defmodule SharedAssigns.IntegrationTest do
  use ExUnit.Case, async: true

  defmodule TestProvider do
    use Phoenix.LiveView

    use SharedAssigns.Provider,
      contexts: [
        theme: "light",
        user_count: 0,
        notifications: []
      ]

    def render(assigns) do
      ~H"""
      <div>
        <.live_component
          module={TestConsumerComponent}
          id="test-consumer"
          theme={@__shared_assigns_contexts__.theme}
          notifications={@__shared_assigns_contexts__.notifications}
        />
      </div>
      """
    end

    def handle_event("change_theme", %{"theme" => theme}, socket) do
      socket = put_context(socket, :theme, theme)
      {:noreply, socket}
    end

    def handle_event("add_notification", %{"message" => message}, socket) do
      socket =
        update_context(socket, :notifications, fn notifications ->
          [%{id: length(notifications) + 1, message: message} | notifications]
        end)

      {:noreply, socket}
    end
  end

  defmodule TestConsumerComponent do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H"""
      <div id={@id}>
        <p>Theme: <%= @theme %></p>
        <p>Notifications: <%= length(@notifications) %></p>
        <div :for={notification <- @notifications}>
          <%= notification.message %>
        </div>
      </div>
      """
    end

    def update(assigns, socket) do
      {:ok, assign(socket, assigns)}
    end

    def subscribed_contexts, do: [:theme, :notifications]
  end

  describe "Full integration with explicit assigns" do
    setup do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        endpoint: SharedAssigns.TestEndpoint,
        view: TestProvider,
        router: nil
      }

      {:ok, mounted_socket} = TestProvider.mount(%{}, %{}, socket)
      {:ok, socket: mounted_socket}
    end

    test "provider initializes contexts in explicit assigns", %{socket: socket} do
      # Verify contexts are in assigns, not process dictionary
      assert socket.assigns[:__shared_assigns_contexts__][:theme] == "light"
      assert socket.assigns[:__shared_assigns_contexts__][:user_count] == 0
      assert socket.assigns[:__shared_assigns_contexts__][:notifications] == []

      # Verify no process dictionary usage
      assert Process.get(:shared_assigns_contexts) == nil
    end

    test "context changes update explicit assigns only", %{socket: socket} do
      # Change a context value
      updated_socket = TestProvider.put_context(socket, :theme, "dark")

      # Verify context is updated in assigns
      assert updated_socket.assigns[:__shared_assigns_contexts__][:theme] == "dark"

      # Verify other contexts remain unchanged
      assert updated_socket.assigns[:__shared_assigns_contexts__][:user_count] == 0

      # Verify version tracking
      assert updated_socket.assigns[:__shared_assigns_versions__][:theme] >
               socket.assigns[:__shared_assigns_versions__][:theme]

      # Verify no process dictionary usage
      assert Process.get(:shared_assigns_contexts) == nil
    end

    test "complex context updates work with explicit assigns", %{socket: socket} do
      # Add a notification using update_context
      updated_socket =
        TestProvider.update_context(socket, :notifications, fn notifications ->
          [%{id: 1, message: "Test notification"} | notifications]
        end)

      # Verify the notification was added
      notifications = updated_socket.assigns[:__shared_assigns_contexts__][:notifications]
      assert length(notifications) == 1
      assert hd(notifications).message == "Test notification"

      # Verify version was incremented
      assert updated_socket.assigns[:__shared_assigns_versions__][:notifications] >
               socket.assigns[:__shared_assigns_versions__][:notifications]
    end

    test "get_context retrieves from explicit assigns", %{socket: socket} do
      # Update a context first
      updated_socket = TestProvider.put_context(socket, :user_count, 42)

      # Verify get_context retrieves from assigns
      assert TestProvider.get_context(updated_socket, :user_count) == 42
      assert TestProvider.get_context(updated_socket, :theme) == "light"
      assert TestProvider.get_context(updated_socket, :nonexistent) == nil
    end
  end

  describe "Component subscription patterns" do
    test "components declare their context dependencies explicitly" do
      # Verify component can declare which contexts it subscribes to
      contexts = TestConsumerComponent.subscribed_contexts()
      assert :theme in contexts
      assert :notifications in contexts
      assert :user_count not in contexts
    end

    test "component update function receives explicit assigns" do
      # This tests that components are designed to receive context via assigns
      # rather than looking it up from process dictionary

      assigns = %{
        id: "test",
        theme: "dark",
        notifications: [%{id: 1, message: "Test"}]
      }

      socket = %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        endpoint: SharedAssigns.TestEndpoint,
        view: TestConsumerComponent,
        router: nil
      }

      {:ok, updated_socket} = TestConsumerComponent.update(assigns, socket)

      # Verify component received the context values as explicit assigns
      assert updated_socket.assigns.theme == "dark"
      assert length(updated_socket.assigns.notifications) == 1
    end
  end

  describe "No process dictionary usage" do
    test "entire flow works without process dictionary" do
      # Clear process dictionary
      Process.delete(:shared_assigns_contexts)
      Process.delete(:shared_assigns_versions)

      # Initialize provider
      socket = %Phoenix.LiveView.Socket{
        assigns: %{__changed__: %{}},
        endpoint: SharedAssigns.TestEndpoint,
        view: TestProvider,
        router: nil
      }

      {:ok, mounted_socket} = TestProvider.mount(%{}, %{}, socket)

      # Update contexts
      updated_socket = TestProvider.put_context(mounted_socket, :theme, "dark")
      updated_socket = TestProvider.put_context(updated_socket, :user_count, 5)

      # Verify everything works
      assert TestProvider.get_context(updated_socket, :theme) == "dark"
      assert TestProvider.get_context(updated_socket, :user_count) == 5

      # Verify process dictionary remains empty
      assert Process.get(:shared_assigns_contexts) == nil
      assert Process.get(:shared_assigns_versions) == nil
    end
  end
end
