defmodule DemoWeb.Components.HeaderComponent do
  @moduledoc """
  Simple header component consuming theme and user contexts.
  """
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, contexts: [:theme, :user]

  def render(assigns) do
    ~H"""
    <header class={[
      "shadow-md p-4 mb-6",
      (@theme || "light") == "dark" && "bg-gray-800 text-white" || "bg-white text-gray-900"
    ]}>
      <div class="max-w-4xl mx-auto flex justify-between items-center">
        <div>
          <h1 class="text-2xl font-bold">SharedAssigns Demo</h1>
          <p class="text-sm opacity-75">Simple context management for Phoenix LiveView</p>
        </div>

        <div class="flex items-center space-x-4">
          <div class={[
            "flex items-center space-x-2 px-3 py-1 rounded-full text-sm",
            case Map.get(@user || %{}, :role, "guest") do
              "admin" -> "bg-yellow-100 text-yellow-800"
              "user" -> "bg-green-100 text-green-800"
              _ -> "bg-gray-100 text-gray-800"
            end
          ]}>
            <span>
              <%= case Map.get(@user || %{}, :role, "guest") do %>
                <% "admin" -> %> 👑
                <% "user" -> %> 👤
                <% _ -> %> 👋
              <% end %>
            </span>
            <span>{Map.get(@user || %{}, :name, "Unknown")}</span>
          </div>

          <div class={[
            "px-3 py-1 rounded-full text-sm",
            @theme == "dark" && "bg-blue-100 text-blue-800" || "bg-yellow-100 text-yellow-800"
          ]}>
            <%= if @theme == "light" do %>
              ☀️ Light
            <% else %>
              🌙 Dark
            <% end %>
          </div>
        </div>
      </div>

      <div class="max-w-4xl mx-auto mt-2 text-xs opacity-60">
        📡 Consumes: <code class="bg-opacity-20 bg-gray-500 px-1 rounded">theme</code>,
        <code class="bg-opacity-20 bg-gray-500 px-1 rounded">user</code>
      </div>
    </header>
    """
  end
end
