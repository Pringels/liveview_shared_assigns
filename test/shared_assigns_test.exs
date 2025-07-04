defmodule SharedAssignsTest do
  use ExUnit.Case, async: true
  import Phoenix.Component

  describe "initialize_contexts/2" do
    test "initializes empty contexts and versions when no initial contexts provided" do
      socket = %Phoenix.LiveView.Socket{assigns: %{}}

      result = SharedAssigns.initialize_contexts(socket, [])

      assert result.assigns.__shared_assigns_contexts__ == %{}
      assert result.assigns.__shared_assigns_versions__ == %{}
    end

    test "initializes with provided initial contexts" do
      socket = %Phoenix.LiveView.Socket{assigns: %{}}
      initial_contexts = [theme: "dark", user_role: "admin"]

      result = SharedAssigns.initialize_contexts(socket, initial_contexts)

      assert result.assigns.__shared_assigns_contexts__ == %{theme: "dark", user_role: "admin"}
      assert result.assigns.__shared_assigns_versions__ == %{theme: 1, user_role: 1}
    end
  end

  describe "put_context/3" do
    test "adds new context with version 1" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __shared_assigns_contexts__: %{},
          __shared_assigns_versions__: %{}
        }
      }

      result = SharedAssigns.put_context(socket, :theme, "light")

      assert result.assigns.__shared_assigns_contexts__.theme == "light"
      assert result.assigns.__shared_assigns_versions__.theme == 1
    end

    test "updates existing context and increments version" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __shared_assigns_contexts__: %{theme: "light"},
          __shared_assigns_versions__: %{theme: 1}
        }
      }

      result = SharedAssigns.put_context(socket, :theme, "dark")

      assert result.assigns.__shared_assigns_contexts__.theme == "dark"
      assert result.assigns.__shared_assigns_versions__.theme == 2
    end
  end

  describe "update_context/3" do
    test "updates context using function and increments version" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __shared_assigns_contexts__: %{count: 1},
          __shared_assigns_versions__: %{count: 1}
        }
      }

      result = SharedAssigns.update_context(socket, :count, &(&1 + 1))

      assert result.assigns.__shared_assigns_contexts__.count == 2
      assert result.assigns.__shared_assigns_versions__.count == 2
    end

    test "creates new context when key doesn't exist" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __shared_assigns_contexts__: %{},
          __shared_assigns_versions__: %{}
        }
      }

      result = SharedAssigns.update_context(socket, :count, fn _ -> 5 end)

      assert result.assigns.__shared_assigns_contexts__.count == 5
      assert result.assigns.__shared_assigns_versions__.count == 1
    end
  end

  describe "get_context/2" do
    test "returns context value when it exists" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __shared_assigns_contexts__: %{theme: "dark"}
        }
      }

      result = SharedAssigns.get_context(socket, :theme)

      assert result == "dark"
    end

    test "returns nil when context doesn't exist" do
      socket = %Phoenix.LiveView.Socket{
        assigns: %{
          __shared_assigns_contexts__: %{}
        }
      }

      result = SharedAssigns.get_context(socket, :theme)

      assert result == nil
    end
  end
end
