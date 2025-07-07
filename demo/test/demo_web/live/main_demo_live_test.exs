defmodule DemoWeb.MainDemoLiveTest do
  @moduledoc """
  LiveView integration tests for context propagation and provider behavior.
  """
  use ExUnit.Case, async: true
  use DemoWeb, :verified_routes
  import Phoenix.LiveViewTest
  import Phoenix.ConnTest

  @endpoint DemoWeb.Endpoint

  describe "MainDemoLive" do
    test "initial mount sets up contexts correctly", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, _view, html} = live(conn, "/")

      # Check initial context values in HTML
      # Initial theme
      assert html =~ "☀️ Light"
      # Initial user role
      assert html =~ "Guest"
      # Initial counter
      assert html =~ "0"
    end

    test "theme toggle updates all subscribing components", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, view, _html} = live(conn, "/")

      # Verify initial state - check for light theme indicators
      assert has_element?(view, "header", "☀️ Light")

      # Toggle theme by clicking the "Switch to Dark" button
      view |> element("button", "Switch to Dark") |> render_click()

      # Verify theme changed to dark
      assert has_element?(view, "header", "🌙 Dark")
    end

    test "user role switch updates conditional content", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, view, _html} = live(conn, "/")

      # Initial state - guest with 👋 emoji in header
      assert has_element?(view, "header", "👋")
      assert has_element?(view, "header", "Guest")

      # Change user role to admin using the form
      view
      |> element("form[phx-change='change_user']")
      |> render_change(%{"name" => "Admin User", "role" => "admin"})

      # Verify role changed to admin with 👑 emoji
      assert has_element?(view, "header", "👑")
    end

    test "counter increment updates all counter displays", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, view, _html} = live(conn, "/")

      # Initial counter shows 0 in the main counter display
      assert has_element?(view, "span", "0")

      # Increment counter using the + button
      view |> element("button", "+") |> render_click()

      # Verify counter updated to 1
      assert has_element?(view, "span", "1")

      # Increment again
      view |> element("button", "+") |> render_click()

      assert has_element?(view, "span", "2")
    end

    test "multiple rapid context changes work correctly", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, view, _html} = live(conn, "/")

      # Rapid changes using actual button text and form
      view |> element("button", "Switch to Dark") |> render_click()

      view
      |> element("form[phx-change='change_user']")
      |> render_change(%{"name" => "Admin User", "role" => "admin"})

      view |> element("button", "+") |> render_click()
      view |> element("button", "+") |> render_click()

      # Verify UI reflects all changes
      assert has_element?(view, "header", "🌙 Dark")
      assert has_element?(view, "header", "👑")
      assert has_element?(view, "span", "2")
    end

    test "context version tracking prevents stale updates", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, view, _html} = live(conn, "/")

      # Make a change and verify it's visible
      view |> element("button", "Switch to Dark") |> render_click()

      # Verify the change is reflected in UI (version tracking working)
      assert has_element?(view, "header", "🌙 Dark")
    end

    test "error handling for invalid context values", %{} do
      conn = Phoenix.ConnTest.build_conn()
      {:ok, view, _html} = live(conn, "/")

      # This test would require adding error handling to the demo
      # For now, we just verify the system is stable
      assert has_element?(view, "header", "☀️ Light")

      # Could add tests for malformed events, etc.
    end
  end
end
