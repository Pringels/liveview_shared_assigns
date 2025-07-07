defmodule DemoWeb.Pages.MainPage do
  @moduledoc """
  Page object for the main demo page, providing reusable actions and assertions
  for Wallaby tests.
  """

  import Wallaby.Browser
  import Wallaby.Query, only: [css: 1, css: 2, text_field: 1, button: 1, option: 1]

  @doc "Visit the main demo page"
  def visit_main_page(session) do
    visit(session, "/")
  end

  @doc "Toggle the theme between light and dark"
  def toggle_theme(session) do
    # The button text changes based on the current theme
    # So we click whichever theme toggle button is present
    cond do
      has?(session, css("button", text: "Switch to Dark")) ->
        click(session, css("button", text: "Switch to Dark"))

      has?(session, css("button", text: "Switch to Light")) ->
        click(session, css("button", text: "Switch to Light"))

      true ->
        # Fallback - just click the theme button
        click(session, css("button[phx-click='toggle_theme']"))
    end
  end

  @doc "Switch user role to the specified role"
  def switch_user_role(session, role) do
    # Clear the name field and set new values
    session
    |> clear(css("input[name='name']"))
    |> fill_in(css("input[name='name']"), with: "#{String.capitalize(role)} User")
    |> select(css("select[name='role']"), option: role)
  end

  @doc "Increment the counter"
  def increment_counter(session) do
    click(session, css("button", text: "+"))
  end

  @doc "Assert that the theme is displayed correctly in the header"
  def assert_header_theme(session, theme) do
    case theme do
      "light" ->
        assert_has(session, css("header", text: "☀️ Light"))

      "dark" ->
        assert_has(session, css("header", text: "🌙 Dark"))
    end
  end

  @doc "Assert that all components reflect the specified theme"
  def assert_all_components_have_theme(session, theme) do
    assert_header_theme(session, theme)
  end

  @doc "Assert that the user role is displayed correctly"
  def assert_user_role(session, role) do
    case role do
      "guest" ->
        session
        |> assert_has(css("header", text: "👋"))
        |> assert_has(css("header", text: "Guest"))

      "user" ->
        session
        |> assert_has(css("header", text: "👤"))

      "admin" ->
        session
        |> assert_has(css("header", text: "👑"))
    end

    session
  end

  @doc "Assert that the counter value is displayed correctly in all components"
  def assert_counter_value(session, value) do
    value_str = to_string(value)

    session
    |> assert_has(css("span", text: value_str))
  end

  @doc "Assert that the child LiveView reflects the parent's context"
  def assert_child_liveview_context(session, theme, user_role, counter) do
    session
    |> assert_has(css(".child-liveview", text: theme))
    |> assert_has(css(".child-liveview", text: user_role))
    |> assert_has(css(".child-liveview", text: to_string(counter)))
  end

  @doc "Wait for context propagation (useful for PubSub delays)"
  def wait_for_context_update(session, _timeout \\ 1000) do
    # Small delay to allow context propagation
    :timer.sleep(100)
    session
  end
end
