defmodule DemoWeb.SimpleWallabyTest do
  @moduledoc """
  Simple Wallaby test without page objects to verify functionality.
  """
  use ExUnit.Case, async: false
  use Wallaby.Feature

  import Wallaby.Browser
  import Wallaby.Query, only: [css: 2]

  @moduletag :integration

  feature "theme toggle functionality", %{session: session} do
    session
    |> visit("/")
    |> assert_has(css("h1", text: "SharedAssigns Demo"))
    |> assert_has(css("header", text: "☀️ Light"))
    |> click(css("button", text: "Switch to Dark"))
    |> assert_has(css("header", text: "🌙 Dark"))
  end

  feature "counter increment functionality", %{session: session} do
    session
    |> visit("/")
    |> assert_has(css("span", text: "0"))
    |> click(css("button", text: "+"))
    |> assert_has(css("span", text: "1"))
    |> click(css("button", text: "+"))
    |> assert_has(css("span", text: "2"))
  end
end
