defmodule DemoWeb.Components.HeaderComponentTest do
  @moduledoc """
  Unit tests for the HeaderComponent to verify context consumption and rendering.
  """
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias DemoWeb.Components.HeaderComponent

  describe "render/1" do
    test "renders with light theme context" do
      assigns = %{
        theme: "light",
        user: %{name: "Test User", role: "user"},
        __sa_version_key: "theme:1|user:1"
      }

      html = render_component(&HeaderComponent.render/1, assigns)

      assert html =~ "☀️ Light"
      assert html =~ "bg-white"
      assert html =~ "text-gray-900"
      assert html =~ "Test User"
      assert html =~ "👤"
    end

    test "renders with dark theme context" do
      assigns = %{
        theme: "dark",
        user: %{name: "Admin User", role: "admin"},
        __sa_version_key: "theme:2|user:1"
      }

      html = render_component(&HeaderComponent.render/1, assigns)

      assert html =~ "🌙 Dark"
      assert html =~ "bg-gray-800"
      assert html =~ "text-white"
      assert html =~ "Admin User"
      assert html =~ "👑"
    end

    test "renders with guest user" do
      assigns = %{
        theme: "light",
        user: %{name: "Unknown", role: "guest"},
        __sa_version_key: "theme:1|user:1"
      }

      html = render_component(&HeaderComponent.render/1, assigns)

      assert html =~ "Unknown"
      assert html =~ "👋"
      assert html =~ "bg-gray-100"
      assert html =~ "text-gray-800"
    end

    test "renders with nil user context" do
      assigns = %{
        theme: "light",
        user: nil,
        __sa_version_key: "theme:1|user:1"
      }

      html = render_component(&HeaderComponent.render/1, assigns)

      assert html =~ "Unknown"
      assert html =~ "👋"
    end

    test "handles missing theme context gracefully" do
      assigns = %{
        theme: nil,
        user: %{name: "Test", role: "user"},
        __sa_version_key: "theme:1|user:1"
      }

      html = render_component(&HeaderComponent.render/1, assigns)

      # Should default to dark theme when theme is nil
      assert html =~ "🌙 Dark"
      # Background is still set by the outer condition
      assert html =~ "bg-white"
    end
  end

  describe "subscribed_contexts/0" do
    test "returns the correct context subscriptions" do
      assert HeaderComponent.subscribed_contexts() == [:theme, :user]
    end
  end
end
