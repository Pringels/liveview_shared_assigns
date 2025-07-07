defmodule DemoWeb.WallabyBasicTest do
  @moduledoc """
  Basic Wallaby test to verify the setup is working.
  """
  use ExUnit.Case, async: false
  use Wallaby.Feature

  import Wallaby.Browser
  import Wallaby.Query, only: [css: 2]

  @moduletag :integration

  feature "basic page load test", %{session: session} do
    session
    |> visit("/")
    |> assert_has(css("h1", text: "SharedAssigns Demo"))
  end
end
