defmodule DemoWeb.Components.UserInfoComponent do
  @moduledoc """
  Simple component that displays user information.
  """
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, contexts: [:user, :theme]

  def update(assigns, socket) do
    IO.inspect(
      %{
        component: __MODULE__,
        user: assigns[:user],
        theme: assigns[:theme],
        version_key: assigns[:__sa_version_key]
      },
      label: "UserInfoComponent.update"
    )

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "rounded-lg shadow-md p-4",
      (@theme || "light") == "dark" && "bg-gray-800" || "bg-white"
    ]}>
      <h3 class="font-bold text-lg mb-3">👤 User Information</h3>

      <div class="space-y-2">
        <div class="flex justify-between">
          <span class="font-medium">Name:</span>
          <span><%= Map.get(@user || %{}, :name, "Unknown") %></span>
        </div>

        <div class="flex justify-between">
          <span class="font-medium">Role:</span>
          <span class={[
            "px-2 py-1 rounded text-sm",
            case Map.get(@user || %{}, :role, "guest") do
              "admin" -> "bg-yellow-100 text-yellow-800"
              "user" -> "bg-green-100 text-green-800"
              _ -> "bg-gray-100 text-gray-800"
            end
          ]}>
            <%= String.capitalize(Map.get(@user || %{}, :role, "guest")) %>
          </span>
        </div>

        <%= if Map.get(@user || %{}, :role, "guest") == "admin" do %>
          <div class="mt-3 p-2 bg-yellow-50 border border-yellow-200 rounded text-sm">
            🔑 Admin privileges active
          </div>
        <% end %>
      </div>

      <div class={[
        "mt-3 text-xs p-2 rounded border",
        (@theme || "light") == "dark" && "bg-gray-700 border-gray-600" || "bg-gray-50 border-gray-200"
      ]}>
        📡 Consumes: <code>user</code>, <code>theme</code>
      </div>
    </div>
    """
  end
end
