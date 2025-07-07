defmodule DemoWeb.MainDemoLive do
  @moduledoc """
  Simple demo showcasing SharedAssigns Provider functionality.
  """
  use Phoenix.LiveView

  use SharedAssigns.Provider,
    contexts: [
      theme: "light",
      user: %{name: "Guest", role: "guest"},
      counter: 0
    ],
    pubsub: Demo.PubSub

  def mount(_params, _session, socket) do
    # Context initialization happens automatically via the Provider macro
    {:ok, socket}
  end

  def handle_event("toggle_theme", _params, socket) do
    current_theme = get_context(socket, :theme)
    new_theme = if current_theme == "light", do: "dark", else: "light"
    {:noreply, put_context(socket, :theme, new_theme)}
  end

  def handle_event("change_user", %{"name" => name, "role" => role}, socket) do
    new_user = %{name: name, role: role}
    {:noreply, put_context(socket, :user, new_user)}
  end

  def handle_event("increment", _params, socket) do
    {:noreply, update_context(socket, :counter, &(&1 + 1))}
  end

  def handle_event("decrement", _params, socket) do
    {:noreply, update_context(socket, :counter, &(&1 - 1))}
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "min-h-screen transition-colors duration-300",
      (@theme || "light") == "dark" && "bg-gray-900 text-white" || "bg-gray-50 text-gray-900"
    ]}>
      <!-- Header Component with seamless SharedAssigns -->
      <.sa_live_component module={DemoWeb.Components.HeaderComponent} id="header" />

      <div class="max-w-4xl mx-auto p-6">
        <!-- Context Controls -->
        <div class={[
          "bg-white rounded-lg shadow-md p-6 mb-6",
          (@theme || "light") == "dark" && "bg-gray-800"
        ]}>
          <h2 class="text-2xl font-bold mb-4">Context Controls</h2>

          <div class="grid md:grid-cols-3 gap-6">
            <!-- Theme Control -->
            <div>
              <h3 class="font-semibold mb-2">Theme</h3>
              <button
                phx-click="toggle_theme"
                class="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded-md transition-colors"
              >
                Switch to <%= if (@theme || "light") == "light", do: "Dark", else: "Light" %>
              </button>
              <p class="text-sm text-gray-500 mt-1">Current: <%= @theme || "light" %></p>
            </div>

            <!-- User Control -->
            <div>
              <h3 class="font-semibold mb-2">User</h3>
              <form phx-change="change_user" class="space-y-2">
                <input
                  type="text"
                  name="name"
                  placeholder="Name"
                  value={Map.get(@user || %{}, :name, "")}
                  class={[
                    "w-full px-3 py-1 border rounded-md",
                    (@theme || "light") == "dark" && "bg-gray-700 border-gray-600 text-white" || "bg-white border-gray-300"
                  ]}
                />
                <select
                  name="role"
                  class={[
                    "w-full px-3 py-1 border rounded-md",
                    (@theme || "light") == "dark" && "bg-gray-700 border-gray-600 text-white" || "bg-white border-gray-300"
                  ]}
                >
                  <option value="guest" selected={Map.get(@user || %{}, :role, "guest") == "guest"}>Guest</option>
                  <option value="user" selected={Map.get(@user || %{}, :role, "guest") == "user"}>User</option>
                  <option value="admin" selected={Map.get(@user || %{}, :role, "guest") == "admin"}>Admin</option>
                </select>
              </form>
            </div>

            <!-- Counter Control -->
            <div>
              <h3 class="font-semibold mb-2">Counter</h3>
              <div class="flex items-center space-x-2">
                <button
                  phx-click="decrement"
                  class="bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-md"
                >
                  -
                </button>
                <span class="font-mono text-lg"><%= @counter || 0 %></span>
                <button
                  phx-click="increment"
                  class="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded-md"
                >
                  +
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- Components Demo with seamless SharedAssigns -->
        <div class="grid md:grid-cols-2 gap-6 mb-6">
          <!-- User Info Component -->
          <.sa_live_component module={DemoWeb.Components.UserInfoComponent} id="user-info" />

          <!-- Counter Display Component -->
          <.sa_live_component module={DemoWeb.Components.CounterDisplayComponent} id="counter-display" />
        </div>

        <!-- Nested Components Demo -->
        <div class="mb-6">
          <h2 class="text-xl font-bold mb-4">Deep Nesting Demo</h2>
          <p class="mb-4">This container has nested SharedAssigns components inside it:</p>
          <.sa_live_component module={DemoWeb.Components.NestedContainerComponent} id="nested-container" />
        </div>

        <!-- Child LiveView Demo -->

        <div class={[
          "bg-blue-50 border-2 border-blue-200 rounded-lg p-6",
          (@theme || "light") == "dark" && "bg-blue-900 border-blue-700"
        ]}>
          <h2 class="text-xl font-bold mb-4">Nested LiveView Demo</h2>
          <p class="mb-4">This section is a separate LiveView that receives contexts from the parent via PubSub:</p>

          <%= live_render(@socket, DemoWeb.ChildDemoLive, id: "child-demo") %>
        </div>

      </div>
    </div>
    """
  end
end
