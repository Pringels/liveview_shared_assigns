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
end
