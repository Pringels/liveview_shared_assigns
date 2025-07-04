defmodule SharedAssignsDemoWeb.PageLive do
  use SharedAssignsDemoWeb, :live_view

  use SharedAssigns.PubSubProvider,
    contexts: [
      theme: "light",
      user_role: "guest"
    ],
    pubsub: SharedAssignsDemo.PubSub

  def mount(_params, _session, socket) do
    # Initialize SharedAssigns contexts
    socket =
      SharedAssigns.initialize_contexts(socket,
        theme: "light",
        user_role: "guest"
      )

    # Also assign contexts to socket assigns for template access
    socket =
      Phoenix.Component.assign(socket, :contexts, %{
        theme: "light",
        user_role: "guest"
      })

    {:ok, socket}
  end

  def handle_event("toggle_theme", _params, socket) do
    current_theme = SharedAssigns.get_context(socket, :theme) || "light"
    new_theme = if current_theme == "light", do: "dark", else: "light"

    socket = put_context(socket, :theme, new_theme)

    socket =
      Phoenix.Component.assign(
        socket,
        :contexts,
        Map.put(socket.assigns.contexts, :theme, new_theme)
      )

    {:noreply, socket}
  end

  def handle_event("change_role", %{"role" => role}, socket) do
    socket = put_context(socket, :user_role, role)

    socket =
      Phoenix.Component.assign(
        socket,
        :contexts,
        Map.put(socket.assigns.contexts, :user_role, role)
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <SharedAssignsDemoWeb.Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
        <!-- Header Component -->
        <.live_component
          module={SharedAssignsDemoWeb.HeaderComponent}
          id="header"
          __parent_contexts__={@contexts}
          __shared_assigns_versions__={@__shared_assigns_versions__}
        />

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
            <!-- Sidebar Component -->
            <div class="lg:col-span-1">
              <.live_component
                module={SharedAssignsDemoWeb.SidebarComponent}
                id="sidebar"
                __parent_contexts__={@contexts}
                __shared_assigns_versions__={@__shared_assigns_versions__}
              />
            </div>
            
    <!-- Main Content -->
            <div class="lg:col-span-3">
              <div class="bg-white rounded-xl shadow-lg p-8">
                <h1 class="text-3xl font-bold text-gray-900 mb-6">SharedAssigns Demo</h1>

                <div class="space-y-6">
                  <div>
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">Theme Controls</h2>
                    <button
                      phx-click="toggle_theme"
                      class="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                    >
                      Toggle Theme (Current: {@contexts.theme})
                    </button>
                  </div>

                  <div>
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">User Role Controls</h2>
                    <div class="flex gap-3">
                      <button
                        phx-click="change_role"
                        phx-value-role="guest"
                        class="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 transition-colors"
                      >
                        Guest
                      </button>
                      <button
                        phx-click="change_role"
                        phx-value-role="user"
                        class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 transition-colors"
                      >
                        User
                      </button>
                      <button
                        phx-click="change_role"
                        phx-value-role="admin"
                        class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
                      >
                        Admin
                      </button>
                    </div>
                    <p class="mt-2 text-sm text-gray-600">
                      Current role: <span class="font-semibold">{@contexts.user_role}</span>
                    </p>
                  </div>
                  
    <!-- User Cards showing granular re-renders -->
                  <div>
                    <h2 class="text-xl font-semibold text-gray-800 mb-4">
                      User Cards (Granular Re-renders)
                    </h2>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                      <.live_component
                        module={SharedAssignsDemoWeb.UserCardComponent}
                        id="user-card-1"
                        user_name="Alice Johnson"
                        subscribed_contexts={[:theme]}
                        __parent_contexts__={@contexts}
                        __shared_assigns_versions__={@__shared_assigns_versions__}
                      />
                      <.live_component
                        module={SharedAssignsDemoWeb.UserCardComponent}
                        id="user-card-2"
                        user_name="Bob Smith"
                        subscribed_contexts={[:user_role]}
                        __parent_contexts__={@contexts}
                        __shared_assigns_versions__={@__shared_assigns_versions__}
                      />
                      <.live_component
                        module={SharedAssignsDemoWeb.UserCardComponent}
                        id="user-card-3"
                        user_name="Carol Davis"
                        subscribed_contexts={[:theme, :user_role]}
                        __parent_contexts__={@contexts}
                        __shared_assigns_versions__={@__shared_assigns_versions__}
                      />
                      <.live_component
                        module={SharedAssignsDemoWeb.UserCardComponent}
                        id="user-card-4"
                        user_name="David Wilson"
                        subscribed_contexts={[]}
                        __parent_contexts__={@contexts}
                        __shared_assigns_versions__={@__shared_assigns_versions__}
                      />
                    </div>
                  </div>
                  
    <!-- Link to Child LiveView -->
                  <div class="mt-8 p-6 bg-purple-50 rounded-lg border border-purple-200">
                    <h3 class="text-lg font-semibold text-purple-900 mb-2">
                      🚀 NEW: Nested LiveView Support
                    </h3>
                    <p class="text-purple-800 mb-4">
                      SharedAssigns now supports context sharing across separate LiveView processes using PubSub!
                    </p>
                    <.link
                      navigate={~p"/child"}
                      class="inline-flex items-center px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                    >
                      View Child LiveView Demo →
                    </.link>
                    <p class="mt-2 text-sm text-purple-700">
                      The child LiveView will automatically receive context updates from this parent!
                    </p>
                  </div>

                  <div class="mt-8 p-4 bg-blue-50 rounded-lg">
                    <h3 class="font-semibold text-blue-900 mb-2">How it works:</h3>
                    <ul class="text-sm text-blue-800 space-y-1">
                      <li>• Each component declares which contexts it needs</li>
                      <li>• Only components using changed contexts re-render</li>
                      <li>• No prop drilling - contexts are accessed directly</li>
                      <li>• Version tracking ensures granular reactivity</li>
                      <li>• <strong>NEW:</strong> PubSub enables cross-LiveView context sharing</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </SharedAssignsDemoWeb.Layouts.app>
    """
  end
end
