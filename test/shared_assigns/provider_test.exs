defmodule SharedAssigns.ProviderTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule TestProvider do
    use Phoenix.LiveView

    use SharedAssigns.Provider,
      contexts: [
        theme: "light",
        user_role: "guest"
      ]

    def mount(_params, _session, socket) do
      {:ok, socket}
    end

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

  @endpoint SharedAssignsDemoWeb.Endpoint

  describe "Provider macro" do
    test "initializes contexts on mount" do
      {:ok, view, _html} = live_isolated(build_conn(), TestProvider)

      # Check that contexts are initialized
      assert view.assigns.__shared_assigns_contexts__.theme == "light"
      assert view.assigns.__shared_assigns_contexts__.user_role == "guest"

      # Check that versions are initialized
      assert view.assigns.__shared_assigns_versions__.theme == 1
      assert view.assigns.__shared_assigns_versions__.user_role == 1
    end

    test "provides helper functions for context management" do
      {:ok, view, _html} = live_isolated(build_conn(), TestProvider)

      # Test put_context functionality
      view = render_click(view, "update_theme", %{"theme" => "dark"})

      # Check that context was updated and version incremented
      assert view.assigns.__shared_assigns_contexts__.theme == "dark"
      assert view.assigns.__shared_assigns_versions__.theme == 2

      # Other contexts should remain unchanged
      assert view.assigns.__shared_assigns_contexts__.user_role == "guest"
      assert view.assigns.__shared_assigns_versions__.user_role == 1
    end

    test "exposes context_keys function" do
      keys = TestProvider.context_keys()
      assert :theme in keys
      assert :user_role in keys
      assert length(keys) == 2
    end
  end

  defp build_conn do
    Phoenix.ConnTest.build_conn()
    |> Plug.Test.init_test_session(%{})
  end
end
