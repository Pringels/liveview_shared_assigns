defmodule SharedAssignsTest do
  use ExUnit.Case, async: true

  defp create_socket(assigns \\ %{}) do
    %Phoenix.LiveView.Socket{
      assigns: Map.merge(%{__changed__: %{}}, assigns),
      endpoint: SharedAssignsDemoWeb.Endpoint,
      view: SharedAssignsDemoWeb.PageLive,
      router: SharedAssignsDemoWeb.Router
    }
  end

  describe "initialize_contexts/2" do
    test "initializes empty contexts and versions when no initial contexts provided" do
      socket = create_socket()

      result = SharedAssigns.initialize_contexts(socket, [])

      assert result.assigns.__shared_assigns_contexts__ == %{}
      assert result.assigns.__shared_assigns_versions__ == %{}
    end

    test "initializes with provided initial contexts" do
      socket = create_socket()
      initial_contexts = [theme: "dark", user_role: "admin"]

      result = SharedAssigns.initialize_contexts(socket, initial_contexts)

      assert result.assigns.__shared_assigns_contexts__ == %{theme: "dark", user_role: "admin"}
      assert result.assigns.__shared_assigns_versions__ == %{theme: 1, user_role: 1}
    end
  end

  describe "put_context/3" do
    test "adds new context with version 1" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{},
          __shared_assigns_versions__: %{}
        })

      result = SharedAssigns.put_context(socket, :theme, "light")

      assert result.assigns.__shared_assigns_contexts__.theme == "light"
      assert result.assigns.__shared_assigns_versions__.theme == 1
    end

    test "updates existing context and increments version" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{theme: "light"},
          __shared_assigns_versions__: %{theme: 1}
        })

      result = SharedAssigns.put_context(socket, :theme, "dark")

      assert result.assigns.__shared_assigns_contexts__.theme == "dark"
      assert result.assigns.__shared_assigns_versions__.theme == 2
    end
  end

  describe "update_context/3" do
    test "updates context using function and increments version" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{count: 1},
          __shared_assigns_versions__: %{count: 1}
        })

      result = SharedAssigns.update_context(socket, :count, &(&1 + 1))

      assert result.assigns.__shared_assigns_contexts__.count == 2
      assert result.assigns.__shared_assigns_versions__.count == 2
    end

    test "creates new context when key doesn't exist" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{},
          __shared_assigns_versions__: %{}
        })

      result = SharedAssigns.update_context(socket, :count, fn _ -> 5 end)

      assert result.assigns.__shared_assigns_contexts__.count == 5
      assert result.assigns.__shared_assigns_versions__.count == 1
    end
  end

  describe "get_context/2" do
    test "returns context value when it exists" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{theme: "dark"}
        })

      result = SharedAssigns.get_context(socket, :theme)

      assert result == "dark"
    end

    test "returns nil when context doesn't exist" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{}
        })

      result = SharedAssigns.get_context(socket, :theme)

      assert result == nil
    end
  end

  describe "get_context_version/2" do
    test "returns version when context exists" do
      socket =
        create_socket(%{
          __shared_assigns_versions__: %{theme: 5}
        })

      result = SharedAssigns.get_context_version(socket, :theme)

      assert result == 5
    end

    test "returns 0 when context doesn't exist" do
      socket =
        create_socket(%{
          __shared_assigns_versions__: %{}
        })

      result = SharedAssigns.get_context_version(socket, :theme)

      assert result == 0
    end
  end

  describe "contexts_changed?/3" do
    test "returns true when context version has increased" do
      socket =
        create_socket(%{
          __shared_assigns_versions__: %{theme: 3, user_role: 2}
        })

      last_versions = %{theme: 2, user_role: 2}

      result = SharedAssigns.contexts_changed?(socket, [:theme, :user_role], last_versions)

      assert result == true
    end

    test "returns false when no contexts have changed" do
      socket =
        create_socket(%{
          __shared_assigns_versions__: %{theme: 2, user_role: 2}
        })

      last_versions = %{theme: 2, user_role: 2}

      result = SharedAssigns.contexts_changed?(socket, [:theme, :user_role], last_versions)

      assert result == false
    end
  end

  describe "extract_contexts/2" do
    test "extracts requested context values" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{theme: "dark", user_role: "admin", other: "value"}
        })

      result = SharedAssigns.extract_contexts(socket, [:theme, :user_role])

      assert result == %{theme: "dark", user_role: "admin"}
    end

    test "returns nil for missing contexts" do
      socket =
        create_socket(%{
          __shared_assigns_contexts__: %{theme: "dark"}
        })

      result = SharedAssigns.extract_contexts(socket, [:theme, :missing])

      assert result == %{theme: "dark", missing: nil}
    end
  end
end
