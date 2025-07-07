defmodule SharedAssignsDemoWeb.PageLive do
  use SharedAssignsDemoWeb, :live_view

  use SharedAssigns.PubSubProvider,
    contexts: [
      theme: "light",
      user_role: "guest",
      sidebar_open: false
    ],
    pubsub: SharedAssignsDemo.PubSub

  def mount(_params, _session, socket) do
    # Initialize SharedAssigns contexts
    socket =
      SharedAssigns.initialize_contexts(socket,
        theme: "light",
        user_role: "guest",
        sidebar_open: false
      )

    # Also assign contexts to socket assigns for template access
    socket =
      Phoenix.Component.assign(socket, :contexts, %{
        theme: "light",
        user_role: "guest",
        sidebar_open: false
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

  def handle_info({:toggle_theme}, socket) do
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

  def handle_event("toggle_sidebar", _params, socket) do
    current_sidebar = SharedAssigns.get_context(socket, :sidebar_open) || false
    new_sidebar = !current_sidebar

    socket = put_context(socket, :sidebar_open, new_sidebar)

    socket =
      Phoenix.Component.assign(
        socket,
        :contexts,
        Map.put(socket.assigns.contexts, :sidebar_open, new_sidebar)
      )

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <SharedAssignsDemoWeb.Layouts.app flash={@flash}>
      <div class={[
        "min-h-screen transition-all duration-500 ease-in-out",
        @contexts.theme == "dark" && "bg-gradient-to-br from-gray-900 via-purple-900 to-violet-900",
        @contexts.theme == "light" && "bg-gradient-to-br from-blue-50 via-indigo-50 to-purple-50"
      ]}>
        <!-- Animated Background Effects -->
        <div class="absolute inset-0 overflow-hidden pointer-events-none">
          <div class={[
            "absolute -top-40 -right-40 w-80 h-80 rounded-full opacity-20 animate-pulse",
            @contexts.theme == "dark" && "bg-purple-500",
            @contexts.theme == "light" && "bg-blue-400"
          ]}>
          </div>
          <div
            class={[
              "absolute -bottom-40 -left-40 w-96 h-96 rounded-full opacity-10 animate-bounce",
              @contexts.theme == "dark" && "bg-violet-500",
              @contexts.theme == "light" && "bg-indigo-400"
            ]}
            style="animation-duration: 3s;"
          >
          </div>
        </div>
        
    <!-- Header Component -->
        <.live_component
          module={SharedAssignsDemoWeb.HeaderComponent}
          id="header"
          __parent_contexts__={@contexts}
          __shared_assigns_versions__={@__shared_assigns_versions__}
        />

        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 relative z-10">
          <div class="grid grid-cols-1 lg:grid-cols-4 gap-8">
            <!-- Dynamic Sidebar Component -->
            <div class={[
              "lg:col-span-1 transition-all duration-500 ease-in-out transform",
              @contexts.sidebar_open && "lg:translate-x-0",
              !@contexts.sidebar_open && "lg:-translate-x-4 lg:opacity-60"
            ]}>
              <.live_component
                module={SharedAssignsDemoWeb.SidebarComponent}
                id="sidebar"
                __parent_contexts__={@contexts}
                __shared_assigns_versions__={@__shared_assigns_versions__}
              />
            </div>
            
    <!-- Main Content -->
            <div class={[
              "transition-all duration-500 ease-in-out",
              @contexts.sidebar_open && "lg:col-span-3",
              !@contexts.sidebar_open && "lg:col-span-4"
            ]}>
              <div class={[
                "rounded-2xl shadow-2xl p-8 mb-8 backdrop-blur-sm transition-all duration-300 hover:shadow-3xl",
                @contexts.theme == "dark" && "bg-gray-800/80 text-white border border-purple-500/20",
                @contexts.theme == "light" && "bg-white/90 text-gray-900 border border-blue-200/50"
              ]}>
                <div class="flex justify-between items-start mb-6">
                  <div>
                    <h1 class={[
                      "text-4xl font-bold mb-2 bg-gradient-to-r bg-clip-text text-transparent",
                      @contexts.theme == "dark" && "from-purple-400 to-pink-400",
                      @contexts.theme == "light" && "from-blue-600 to-purple-600"
                    ]}>
                      SharedAssigns Demo
                    </h1>
                    <p class={[
                      "text-lg opacity-80",
                      @contexts.theme == "dark" && "text-gray-300",
                      @contexts.theme == "light" && "text-gray-600"
                    ]}>
                      React Context for Phoenix LiveView • Role:
                      <span class={[
                        "font-bold px-2 py-1 rounded-full text-sm ml-1",
                        @contexts.user_role == "admin" && "bg-red-100 text-red-800",
                        @contexts.user_role == "user" && "bg-green-100 text-green-800",
                        @contexts.user_role == "guest" && "bg-gray-100 text-gray-800"
                      ]}>
                        {@contexts.user_role}
                      </span>
                    </p>
                  </div>
                  
    <!-- Sidebar Toggle -->
                  <button
                    phx-click="toggle_sidebar"
                    class={[
                      "p-3 rounded-full transition-all duration-300 hover:scale-110",
                      @contexts.theme == "dark" && "bg-purple-600 hover:bg-purple-500 text-white",
                      @contexts.theme == "light" && "bg-blue-600 hover:bg-blue-500 text-white"
                    ]}
                  >
                    <%= if @contexts.sidebar_open do %>
                      ← Hide
                    <% else %>
                      → Show
                    <% end %>
                  </button>
                </div>

                <div class="space-y-8">
                  <!-- Theme Controls -->
                  <div class="space-y-4">
                    <h2 class={[
                      "text-2xl font-semibold flex items-center",
                      @contexts.theme == "dark" && "text-purple-300",
                      @contexts.theme == "light" && "text-blue-800"
                    ]}>
                      🎨 Theme Controls
                      <div class={[
                        "ml-3 w-4 h-4 rounded-full animate-pulse",
                        @contexts.theme == "dark" && "bg-purple-400",
                        @contexts.theme == "light" && "bg-blue-400"
                      ]}>
                      </div>
                    </h2>
                    <button
                      phx-click="toggle_theme"
                      class={[
                        "group px-8 py-4 rounded-xl font-semibold transition-all duration-300 transform hover:scale-105 hover:shadow-lg",
                        @contexts.theme == "dark" &&
                          "bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-500 hover:to-pink-500 text-white",
                        @contexts.theme == "light" &&
                          "bg-gradient-to-r from-blue-600 to-purple-600 hover:from-blue-500 hover:to-purple-500 text-white"
                      ]}
                    >
                      <span class="group-hover:animate-pulse">
                        {if @contexts.theme == "dark",
                          do: "☀️ Switch to Light",
                          else: "🌙 Switch to Dark"}
                      </span>
                      <span class="ml-2 text-sm opacity-80">(Current: {@contexts.theme})</span>
                    </button>
                  </div>
                  
    <!-- Role Controls -->
                  <div class="space-y-4">
                    <h2 class={[
                      "text-2xl font-semibold flex items-center",
                      @contexts.theme == "dark" && "text-purple-300",
                      @contexts.theme == "light" && "text-blue-800"
                    ]}>
                      👤 User Role Controls
                      <span class={[
                        "ml-3 text-sm px-2 py-1 rounded-full",
                        @contexts.user_role == "admin" && "bg-red-200 text-red-800",
                        @contexts.user_role == "user" && "bg-green-200 text-green-800",
                        @contexts.user_role == "guest" && "bg-gray-200 text-gray-800"
                      ]}>
                        Active: {@contexts.user_role}
                      </span>
                    </h2>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                      <button
                        phx-click="change_role"
                        phx-value-role="guest"
                        class={[
                          "group p-4 rounded-xl border-2 transition-all duration-300 transform hover:scale-105",
                          @contexts.user_role == "guest" && "border-gray-500 bg-gray-100 shadow-lg",
                          @contexts.user_role != "guest" &&
                            "border-gray-300 hover:border-gray-400 hover:bg-gray-50"
                        ]}
                      >
                        <div class="text-center">
                          <div class="text-2xl mb-2">🚶</div>
                          <div class="font-semibold text-gray-700">Guest</div>
                          <div class="text-xs text-gray-500 mt-1">Basic access</div>
                        </div>
                      </button>
                      <button
                        phx-click="change_role"
                        phx-value-role="user"
                        class={[
                          "group p-4 rounded-xl border-2 transition-all duration-300 transform hover:scale-105",
                          @contexts.user_role == "user" && "border-green-500 bg-green-100 shadow-lg",
                          @contexts.user_role != "user" &&
                            "border-green-300 hover:border-green-400 hover:bg-green-50"
                        ]}
                      >
                        <div class="text-center">
                          <div class="text-2xl mb-2">👨‍💼</div>
                          <div class="font-semibold text-green-700">User</div>
                          <div class="text-xs text-green-600 mt-1">Dashboard access</div>
                        </div>
                      </button>
                      <button
                        phx-click="change_role"
                        phx-value-role="admin"
                        class={[
                          "group p-4 rounded-xl border-2 transition-all duration-300 transform hover:scale-105",
                          @contexts.user_role == "admin" && "border-red-500 bg-red-100 shadow-lg",
                          @contexts.user_role != "admin" &&
                            "border-red-300 hover:border-red-400 hover:bg-red-50"
                        ]}
                      >
                        <div class="text-center">
                          <div class="text-2xl mb-2">👑</div>
                          <div class="font-semibold text-red-700">Admin</div>
                          <div class="text-xs text-red-600 mt-1">Full control</div>
                        </div>
                      </button>
                    </div>
                  </div>
                  
    <!-- User Cards showing granular re-renders -->
                  <div class="space-y-4">
                    <h2 class={[
                      "text-2xl font-semibold",
                      @contexts.theme == "dark" && "text-purple-300",
                      @contexts.theme == "light" && "text-blue-800"
                    ]}>
                      🎭 Context Subscription Examples
                    </h2>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
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
                </div>
              </div>
              
    <!-- Embedded Nested LiveView -->
              <div class={[
                "rounded-2xl shadow-2xl p-8 border-2 backdrop-blur-sm transition-all duration-300 hover:shadow-3xl",
                @contexts.theme == "dark" && "bg-purple-900/80 border-purple-500/50 text-white",
                @contexts.theme == "light" && "bg-purple-50/90 border-purple-200 text-gray-900"
              ]}>
                <div class="mb-6">
                  <h2 class={[
                    "text-3xl font-bold mb-3 flex items-center bg-gradient-to-r bg-clip-text text-transparent",
                    @contexts.theme == "dark" && "from-purple-400 to-pink-400",
                    @contexts.theme == "light" && "from-purple-600 to-pink-600"
                  ]}>
                    🚀 Nested LiveView (Cross-Process) <span class="ml-3 animate-bounce">⚡</span>
                  </h2>
                  <p class={[
                    "text-lg",
                    @contexts.theme == "dark" && "text-purple-200",
                    @contexts.theme == "light" && "text-purple-800"
                  ]}>
                    This is a separate LiveView process running within the parent,
                    automatically receiving context updates via PubSub!
                  </p>
                </div>

                {live_render(@socket, SharedAssignsDemoWeb.ChildLive,
                  id: :embedded_child,
                  session: %{}
                )}
              </div>

              <div class={[
                "mt-8 p-6 rounded-xl backdrop-blur-sm",
                @contexts.theme == "dark" && "bg-blue-900/50 border border-blue-700/50",
                @contexts.theme == "light" && "bg-blue-50/90 border border-blue-200"
              ]}>
                <h3 class={[
                  "font-bold mb-3 text-lg",
                  @contexts.theme == "dark" && "text-blue-300",
                  @contexts.theme == "light" && "text-blue-900"
                ]}>
                  💡 How SharedAssigns eliminates prop drilling:
                </h3>
                <ul class={[
                  "space-y-2 text-sm",
                  @contexts.theme == "dark" && "text-blue-200",
                  @contexts.theme == "light" && "text-blue-800"
                ]}>
                  <li class="flex items-center">
                    <span class="w-2 h-2 bg-green-500 rounded-full mr-3 animate-pulse"></span>
                    Parent LiveView provides contexts with zero boilerplate
                  </li>
                  <li class="flex items-center">
                    <span
                      class="w-2 h-2 bg-yellow-500 rounded-full mr-3 animate-pulse"
                      style="animation-delay: 0.2s;"
                    >
                    </span>
                    Components subscribe only to contexts they need
                  </li>
                  <li class="flex items-center">
                    <span
                      class="w-2 h-2 bg-purple-500 rounded-full mr-3 animate-pulse"
                      style="animation-delay: 0.4s;"
                    >
                    </span>
                    Granular re-renders - only subscribed components update
                  </li>
                  <li class="flex items-center">
                    <span
                      class="w-2 h-2 bg-pink-500 rounded-full mr-3 animate-pulse"
                      style="animation-delay: 0.6s;"
                    >
                    </span>
                    Cross-process support via PubSub for nested LiveViews
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </SharedAssignsDemoWeb.Layouts.app>
    """
  end
end
