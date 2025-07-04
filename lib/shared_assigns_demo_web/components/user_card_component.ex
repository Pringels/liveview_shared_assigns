defmodule SharedAssignsDemoWeb.UserCardComponent do
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, keys: [:theme, :user_role]

  attr :user_name, :string, required: true
  attr :user_role, :string, required: true
  attr :user_initials, :string, required: true
  attr :color, :string, default: "blue"
  attr :status, :string, default: "online"
  attr :context_type, :string, required: true

  def render(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
      <div class="flex items-center space-x-4">
        <div class={[
          "w-12 h-12 rounded-full flex items-center justify-center",
          case @color do
            "blue" -> "bg-blue-500"
            "green" -> "bg-green-500"
            "purple" -> "bg-purple-500"
            "red" -> "bg-red-500"
            _ -> "bg-gray-500"
          end
        ]}>
          <span class="text-white font-semibold">{@user_initials}</span>
        </div>
        <div>
          <h3 class="text-lg font-semibold text-gray-900 dark:text-white">{@user_name}</h3>
          <p class="text-sm text-gray-600 dark:text-gray-400">{@user_role}</p>
        </div>
      </div>

      <div class="mt-4 space-y-2">
        <p class="text-sm text-gray-700 dark:text-gray-300">
          This component consumes {@context_type} context
        </p>
        <div class="flex space-x-2">
          <span class={[
            "px-2 py-1 text-xs rounded",
            case @status do
              "online" -> "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200"
              "away" -> "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200"
              "offline" -> "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
              _ -> "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
            end
          ]}>
            {String.capitalize(@status)}
          </span>

          <%= if @context_type == "theme" do %>
            <span class="px-2 py-1 text-xs bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200 rounded">
              Theme: {String.capitalize(@theme || "light")}
            </span>
          <% end %>

          <%= if @context_type == "user_role" do %>
            <span class="px-2 py-1 text-xs bg-purple-100 text-purple-800 dark:bg-purple-900 dark:text-purple-200 rounded">
              Role: {String.capitalize(@user_role || "guest")}
            </span>
          <% end %>
        </div>
        
    <!-- Re-render counter to show granular updates -->
        <div class="mt-3 p-2 bg-gray-50 dark:bg-gray-700 rounded text-xs">
          <p class="text-gray-600 dark:text-gray-400">
            Last updated: {DateTime.utc_now() |> DateTime.to_string() |> String.slice(11, 8)}
          </p>
          <p class="text-gray-600 dark:text-gray-400">
            Watching: {@context_type} context
          </p>
        </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end
end
