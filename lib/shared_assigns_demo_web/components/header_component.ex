defmodule SharedAssignsDemoWeb.HeaderComponent do
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, contexts: [:theme]

  def render(assigns) do
    ~H"""
    <header class="bg-white shadow-sm border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center space-x-4">
            <h1 class="text-xl font-bold text-gray-900 dark:text-white">SharedAssigns Demo</h1>
            <span class="px-2 py-1 text-xs font-medium bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200 rounded-full">
              Theme: {String.capitalize(@theme || "light")}
            </span>
          </div>
          <div class="flex items-center space-x-4">
            <button
              phx-click="toggle_theme"
              phx-target={@myself}
              class="px-3 py-1 text-sm bg-blue-500 text-white rounded hover:bg-blue-600 transition-colors"
            >
              Toggle Theme
            </button>
            <div class="text-sm text-gray-600">
              Last updated: {DateTime.utc_now() |> DateTime.to_time() |> Time.to_string()}
            </div>
          </div>
        </div>
      </div>
    </header>
    """
  end

  def handle_event("toggle_theme", _params, socket) do
    # Forward to parent LiveView
    send(self(), {:toggle_theme})
    {:noreply, socket}
  end
end
