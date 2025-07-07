defmodule DemoWeb.Components.CounterDisplayComponent do
  @moduledoc """
  Simple component that displays counter with visual feedback.
  """
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, contexts: [:counter, :theme]

  def update(assigns, socket) do
    IO.inspect(
      %{
        component: __MODULE__,
        counter: assigns[:counter],
        theme: assigns[:theme],
        version_key: assigns[:__sa_version_key]
      },
      label: "CounterDisplayComponent.update"
    )

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "rounded-lg shadow-md p-4",
      (@theme || "light") == "dark" && "bg-gray-800" || "bg-white"
    ]}>
      <h3 class="font-bold text-lg mb-3">🔢 Counter Display</h3>

      <div class="text-center">
        <div class={[
          "text-4xl font-mono font-bold mb-2",
          cond do
            (@counter || 0) > 0 -> "text-green-500"
            (@counter || 0) < 0 -> "text-red-500"
            true -> "text-gray-500"
          end
        ]}>
          <%= @counter || 0 %>
        </div>

        <div class="flex justify-center space-x-2 mb-3">
          <%= for _ <- 1..min(abs(@counter || 0), 10) do %>
            <div class={[
              "w-2 h-2 rounded-full",
              if (@counter || 0) > 0 do
                "bg-green-400"
              else
                "bg-red-400"
              end
            ]}>
            </div>
          <% end %>
          <%= if abs(@counter || 0) > 10 do %>
            <span class="text-sm text-gray-500">...+<%= abs(@counter || 0) - 10 %></span>
          <% end %>
        </div>

        <p class="text-sm text-gray-500">
          <%= cond do %>
            <% (@counter || 0) > 0 -> %> Positive value! 📈
            <% (@counter || 0) < 0 -> %> Negative value! 📉
            <% true -> %> Zero value 🎯
          <% end %>
        </p>
      </div>

      <div class={[
        "mt-3 text-xs p-2 rounded border",
        (@theme || "light") == "dark" && "bg-gray-700 border-gray-600" || "bg-gray-50 border-gray-200"
      ]}>
        📡 Consumes: <code>counter</code>, <code>theme</code>
      </div>
    </div>
    """
  end
end
