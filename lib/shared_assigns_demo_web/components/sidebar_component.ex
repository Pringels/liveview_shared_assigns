defmodule SharedAssignsDemoWeb.SidebarComponent do
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, contexts: [:user_role]

  import SharedAssignsDemoWeb.CoreComponents

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-xl shadow-lg p-6">
      <h2 class="text-lg font-semibold text-gray-900 mb-4">Navigation</h2>

      <div class="space-y-2">
        <%= if @user_role == :admin do %>
          <a
            href="#"
            class="flex items-center space-x-3 px-3 py-2 text-sm font-medium text-red-600 bg-red-50 rounded-lg hover:bg-red-100 transition-colors"
          >
            <.icon name="hero-cog-6-tooth" class="w-4 h-4" />
            <span>Admin Panel</span>
          </a>
          <a
            href="#"
            class="flex items-center space-x-3 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <.icon name="hero-users" class="w-4 h-4" />
            <span>Manage Users</span>
          </a>
        <% end %>

        <%= if @user_role in [:user, :admin] do %>
          <a
            href="#"
            class="flex items-center space-x-3 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <.icon name="hero-document-text" class="w-4 h-4" />
            <span>My Documents</span>
          </a>
          <a
            href="#"
            class="flex items-center space-x-3 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <.icon name="hero-user-circle" class="w-4 h-4" />
            <span>Profile</span>
          </a>
        <% end %>

        <a
          href="#"
          class="flex items-center space-x-3 px-3 py-2 text-sm font-medium text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
        >
          <.icon name="hero-home" class="w-4 h-4" />
          <span>Dashboard</span>
        </a>
      </div>

      <div class="mt-6 pt-6 border-t border-gray-200">
        <div class="text-sm text-gray-600">
          <span class="font-medium">Current Role:</span>
          <span class="capitalize ml-1 px-2 py-1 bg-blue-100 text-blue-800 rounded-full text-xs">
            {@user_role}
          </span>
        </div>
        <div class="text-xs text-gray-500 mt-2">
          Only shows nav items for your role
        </div>
      </div>
    </div>
    """
  end
end
