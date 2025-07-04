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

  defmodule TestEndpoint do
    use Phoenix.Endpoint, otp_app: :shared_assigns_demo

    socket "/live", Phoenix.LiveView.Socket,
      websocket: [connect_info: [session: @session_options]]
  end

  defmodule TestRouter do
    use Phoenix.Router
    import Phoenix.LiveView.Router

    scope "/" do
      pipe_through :browser
      live "/test", SharedAssigns.ProviderTest.TestProvider
    end

    pipeline :browser do
      plug :accepts, ["html"]
      plug :fetch_session
      plug :fetch_live_flash
      plug :put_root_layout, {SharedAssignsDemoWeb.Layouts, :root}
      plug :protect_from_forgery
      plug :put_secure_browser_headers
    end
  end

  @endpoint TestEndpoint

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
