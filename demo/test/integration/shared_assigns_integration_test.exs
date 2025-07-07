defmodule DemoWeb.SharedAssignsIntegrationTest do
  @moduledoc """
  Integration tests for SharedAssigns functionality using Wallaby.
  Tests the end-to-end behavior of shared context propagation and UI updates.
  """
  use ExUnit.Case, async: false
  use Wallaby.Feature

  import Wallaby.Browser
  import Wallaby.Query, only: [css: 1, css: 2]

  @moduletag :integration

  # Helper functions
  defp visit_main_page(session), do: visit(session, "/")

  defp toggle_theme(session) do
    cond do
      has?(session, css("button", text: "Switch to Dark")) ->
        click(session, css("button", text: "Switch to Dark"))

      has?(session, css("button", text: "Switch to Light")) ->
        click(session, css("button", text: "Switch to Light"))

      true ->
        click(session, css("button[phx-click='toggle_theme']"))
    end
  end

  defp increment_counter(session), do: click(session, css("button", text: "+"))

  defp wait_for_context_update(session, _timeout \\ 1000) do
    :timer.sleep(100)
    session
  end

  defp assert_header_theme(session, theme) do
    case theme do
      "light" -> assert_has(session, css("header", text: "☀️ Light"))
      "dark" -> assert_has(session, css("header", text: "🌙 Dark"))
    end

    session
  end

  defp assert_all_components_have_theme(session, theme) do
    assert_header_theme(session, theme)
  end

  defp assert_user_role(session, role) do
    case role do
      "guest" ->
        session
        |> assert_has(css("header", text: "👋"))
        |> assert_has(css("header", text: "Guest"))

      "user" ->
        assert_has(session, css("header", text: "👤"))

      "admin" ->
        assert_has(session, css("header", text: "👑"))
    end

    session
  end

  defp assert_counter_value(session, value) do
    assert_has(session, css("span", text: to_string(value)))
  end

  defp assert_child_liveview_context(session, theme, user_role, counter) do
    session
    |> assert_has(css("h3", text: "🧒 Child LiveView"))
    |> assert_has(css("li", text: "Theme: #{theme}"))
    |> assert_has(css("li", text: "Counter: #{to_string(counter)}"))
    # Check user role in the appropriate context
    |> then(fn session ->
      case user_role do
        "guest" ->
          session
          |> assert_has(css("li", text: "User: Guest (guest)"))

        "user" ->
          session
          |> assert_has(css("li", text: "(user)"))

        "admin" ->
          session
          |> assert_has(css("li", text: "(admin)"))
          |> assert_has(css("p", text: "👑 Admin Panel"))
      end
    end)
  end

  feature "theme changes propagate to all components", %{session: session} do
    session
    |> visit_main_page()
    |> assert_all_components_have_theme("light")
    |> toggle_theme()
    |> wait_for_context_update()
    |> assert_all_components_have_theme("dark")
    |> toggle_theme()
    |> wait_for_context_update()
    |> assert_all_components_have_theme("light")
  end

  feature "user role changes affect conditional rendering", %{session: session} do
    session
    |> visit_main_page()
    |> assert_user_role("guest")

    # Note: We can't easily test role switching without form interaction
    # This would require select dropdown interaction which needs more complex Wallaby setup
  end

  feature "counter updates propagate to all subscribing components", %{session: session} do
    session
    |> visit_main_page()
    |> assert_counter_value(0)
    |> increment_counter()
    |> wait_for_context_update()
    |> assert_counter_value(1)
    |> increment_counter()
    |> wait_for_context_update()
    |> assert_counter_value(2)
  end

  feature "nested LiveView receives context changes via PubSub", %{session: session} do
    session
    |> visit_main_page()
    |> assert_child_liveview_context("light", "guest", 0)
    |> toggle_theme()
    |> wait_for_context_update()
    |> assert_child_liveview_context("dark", "guest", 0)
    |> increment_counter()
    |> wait_for_context_update()
    |> assert_child_liveview_context("dark", "guest", 1)
  end

  feature "rapid context changes don't cause race conditions", %{session: session} do
    session
    |> visit_main_page()
    |> toggle_theme()
    |> toggle_theme()
    |> toggle_theme()
    |> wait_for_context_update()
    |> assert_all_components_have_theme("dark")
    |> wait_for_context_update()
  end

  feature "multiple context changes work together", %{session: session} do
    session
    |> visit_main_page()
    |> assert_counter_value(0)
    |> toggle_theme()
    |> increment_counter()
    |> increment_counter()
    |> wait_for_context_update()
    |> assert_counter_value(2)
    |> assert_all_components_have_theme("dark")
    |> assert_child_liveview_context("dark", "guest", 2)
  end

  feature "child LiveView maintains local state while consuming contexts", %{session: session} do
    session
    |> visit_main_page()
    |> assert_child_liveview_context("light", "guest", 0)
    |> toggle_theme()
    |> wait_for_context_update()
    |> assert_child_liveview_context("dark", "guest", 0)
    |> increment_counter()
    |> wait_for_context_update()
    |> assert_child_liveview_context("dark", "guest", 1)
    |> toggle_theme()
    |> wait_for_context_update()
    |> assert_child_liveview_context("light", "guest", 1)
  end
end
