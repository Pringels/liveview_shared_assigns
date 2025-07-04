defmodule SharedAssignsDemoWeb.SidebarComponent do
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, keys: [:user_role]

  def render(assigns) do
    ~H"""
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
      <h2 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">Navigation</h2>
      <nav class="space-y-2">
        <a
          href="#"
          class="flex items-center px-3 py-2 text-sm font-medium text-blue-600 bg-blue-50 dark:bg-blue-900 dark:text-blue-200 rounded-lg"
        >
          <.icon name="hero-home" class="w-4 h-4 mr-3" /> Dashboard
        </a>
        <a
          href="#"
          class="flex items-center px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg"
        >
          <.icon name="hero-user" class="w-4 h-4 mr-3" /> Profile
        </a>

        <%= if @user_role in ["admin"] do %>
          <a
            href="#"
            class="flex items-center px-3 py-2 text-sm font-medium text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900 rounded-lg"
          >
            <.icon name="hero-cog-6-tooth" class="w-4 h-4 mr-3" /> Admin Panel
          </a>
        <% end %>

        <%= if @user_role in ["user", "admin"] do %>
          <a
            href="#"
            class="flex items-center px-3 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-gray-700 rounded-lg"
          >
            <.icon name="hero-document-text" class="w-4 h-4 mr-3" /> Reports
          </a>
        <% end %>
      </nav>

      <div class="mt-6 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
        <p class="text-sm text-gray-600 dark:text-gray-400 mb-2">Current Role:</p>
        <span class={[
          "px-2 py-1 text-xs font-medium rounded-full",
          case @user_role do
            "admin" -> "bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200"
            "user" -> "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200"
            _ -> "bg-gray-100 text-gray-800 dark:bg-gray-900 dark:text-gray-200"
          end
        ]}>
          {String.capitalize(@user_role || "guest")}
        </span>
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
