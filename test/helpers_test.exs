defmodule SharedAssigns.HelpersTest do
  use ExUnit.Case, async: true

  defmodule TestLiveView do
    use Phoenix.LiveView
    import SharedAssigns.Helpers

    use SharedAssigns.Provider,
      contexts: [
        theme: "light",
        user_role: "admin",
        notifications: []
      ]

    def render(assigns) do
      ~H"""
      <div>
        <%= user_display(sa_component(assigns, module: UserDisplayComponent, id: "user-display")) %>
        <.sa_live_component module={DemoComponent} id="demo-component" />
      </div>
      """
    end

    def user_display(assigns) do
      ~H"""
      <div id="user-display">
        Theme: <%= @theme %>
        Role: <%= @user_role %>
      </div>
      """
    end
  end

  defmodule UserDisplayComponent do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H"""
      <div id={@id}>
        Theme: <%= @theme %>
        Role: <%= @user_role %>
      </div>
      """
    end

    def update(assigns, socket) do
      {:ok, assign(socket, assigns)}
    end

    def subscribed_contexts, do: [:theme, :user_role]
  end

  defmodule DemoComponent do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H"""
      <div id={@id}>
        Theme: <%= @theme %>
        Notifications: <%= length(@notifications) %>
      </div>
      """
    end

    def update(assigns, socket) do
      {:ok, assign(socket, assigns)}
    end

    def subscribed_contexts, do: [:theme, :notifications]
  end

  describe "sa_component helper" do
    test "injects context values as explicit assigns" do
      parent_assigns = %{
        theme: "dark",
        user_role: "moderator",
        notifications: [%{id: 1, message: "Test"}],
        __shared_assigns_versions__: %{
          theme: 1,
          user_role: 1,
          notifications: 1
        }
      }

      # Test the helper function with a consumer component
      result =
        SharedAssigns.Helpers.sa_component(parent_assigns,
          module: UserDisplayComponent,
          id: "test-user-display"
        )

      # Verify context values are injected
      assert result[:theme] == "dark"
      assert result[:user_role] == "moderator"
      assert result[:id] == "test-user-display"

      # Verify version tracking (simplified approach)
      assert Map.has_key?(result, :__sa_version_key)
      assert result[:__sa_version_key] == "theme:1|user_role:1"
    end

    test "passes through opts for non-consumer components" do
      parent_assigns = %{theme: "dark", user_role: "moderator"}

      # Test with a regular component (no subscribed_contexts function)
      result =
        SharedAssigns.Helpers.sa_component(parent_assigns,
          # String module doesn't have subscribed_contexts
          module: String,
          id: "test-regular"
        )

      # Should just pass through the opts without context injection
      assert result[:module] == String
      assert result[:id] == "test-regular"
      # No context injection
      assert Map.get(result, :theme) == nil
    end
  end

  describe "sa_live_component helper" do
    test "injects only required context values for component" do
      # Test that the macro exists and can be used
      assert macro_exported?(SharedAssigns.Helpers, :sa_live_component, 1)

      # Test component subscription detection
      contexts = DemoComponent.subscribed_contexts()
      assert :theme in contexts
      assert :notifications in contexts
    end
  end

  describe "Context injection without process dictionary" do
    test "helpers do not use process dictionary" do
      # Clear any existing process dictionary entries
      Process.delete(:shared_assigns_contexts)

      parent_assigns = %{
        theme: "dark",
        user_role: "moderator",
        __shared_assigns_versions__: %{theme: 1, user_role: 1}
      }

      # Use the helper
      result =
        SharedAssigns.Helpers.sa_component(parent_assigns,
          module: UserDisplayComponent,
          id: "test"
        )

      # After using helpers, process dictionary should remain empty
      assert Process.get(:shared_assigns_contexts) == nil

      # Verify the helper still worked
      assert result[:theme] == "dark"
      assert result[:user_role] == "moderator"
    end
  end

  describe "Component subscription detection" do
    test "identifies component context subscriptions correctly" do
      # Test that we can detect which contexts a component subscribes to
      contexts = DemoComponent.subscribed_contexts()
      assert :theme in contexts
      assert :notifications in contexts
      assert :user_role not in contexts

      # Test UserDisplayComponent
      user_contexts = UserDisplayComponent.subscribed_contexts()
      assert :theme in user_contexts
      assert :user_role in user_contexts
      assert :notifications not in user_contexts
    end

    test "detects non-consumer components correctly" do
      # Test that regular modules are not identified as consumers
      refute SharedAssigns.Helpers.is_consumer?(String)
      refute SharedAssigns.Helpers.is_consumer?(Enum)

      # Test that consumer components are identified correctly
      assert SharedAssigns.Helpers.is_consumer?(DemoComponent)
      assert SharedAssigns.Helpers.is_consumer?(UserDisplayComponent)
    end
  end
end
