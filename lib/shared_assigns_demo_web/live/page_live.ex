defmodule SharedAssignsDemoWeb.PageLive do
  use SharedAssignsDemoWeb, :live_view

  use SharedAssigns.Provider,
    contexts: [
      theme: "light",
      user_role: "guest",
      notifications: []
    ]

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_event("toggle_theme", _params, socket) do
    current_theme = get_context(socket, :theme)
    new_theme = if current_theme == "light", do: "dark", else: "light"
    socket = put_context(socket, :theme, new_theme)
    {:noreply, socket}
  end

  def handle_event("switch_role", _params, socket) do
    current_role = get_context(socket, :user_role)

    new_role =
      case current_role do
        "guest" -> "user"
        "user" -> "admin"
        "admin" -> "guest"
        _ -> "guest"
      end

    socket = put_context(socket, :user_role, new_role)
    {:noreply, socket}
  end

  def handle_event("add_notification", %{"message" => message}, socket) do
    new_notification = %{
      id: System.unique_integer([:positive]),
      message: message,
      timestamp: DateTime.utc_now()
    }

    socket =
      update_context(socket, :notifications, [], fn notifications ->
        [new_notification | notifications]
      end)

    {:noreply, socket}
  end

  def handle_event("clear_notifications", _params, socket) do
    socket = put_context(socket, :notifications, [])
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800">
        <!-- Header Component -->
        <.live_component module={SharedAssignsDemoWeb.HeaderComponent} id="header" />

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
            <!-- Sidebar Component -->
            <div class="lg:col-span-1">
              <.live_component module={SharedAssignsDemoWeb.SidebarComponent} id="sidebar" />
            </div>
            
    <!-- Main Content -->
            <div class="lg:col-span-3">
              <!-- User Cards showing granular re-renders -->
              <div class="mb-8">
                <h2 class="text-2xl font-bold text-gray-900 dark:text-white mb-6">
                  SharedAssigns Library Demo
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <.live_component
                    module={SharedAssignsDemoWeb.UserCardComponent}
                    id="user-card-1"
                    user_name="John Doe"
                    user_role="Product Manager"
                    user_initials="JD"
                    color="blue"
                    status="online"
                    context_type="theme"
                  />

                  <.live_component
                    module={SharedAssignsDemoWeb.UserCardComponent}
                    id="user-card-2"
                    user_name="Jane Smith"
                    user_role="Designer"
                    user_initials="JS"
                    color="green"
                    status="away"
                    context_type="user_role"
                  />
                </div>
              </div>
              
    <!-- Features explanation -->
              <div class="bg-white dark:bg-gray-800 rounded-lg shadow-sm p-6 border border-gray-200 dark:border-gray-700">
                <h3 class="text-lg font-semibold text-gray-900 dark:text-white mb-4">
                  SharedAssigns Features
                </h3>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="space-y-3">
                    <div class="flex items-start space-x-3">
                      <div class="w-6 h-6 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5">
                        <.icon name="hero-check" class="w-3 h-3 text-white" />
                      </div>
                      <div>
                        <p class="text-sm font-medium text-gray-900 dark:text-white">
                          Zero Prop Drilling
                        </p>
                        <p class="text-xs text-gray-600 dark:text-gray-400">
                          Access context from any component
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
