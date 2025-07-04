defmodule SharedAssignsDemoWeb.ErrorJSONTest do
  use SharedAssignsDemoWeb.ConnCase, async: true

  test "renders 404" do
    assert SharedAssignsDemoWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert SharedAssignsDemoWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
