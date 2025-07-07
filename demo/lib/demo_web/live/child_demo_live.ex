defmodule DemoWeb.ChildDemoLive do
  @moduledoc """
  Simple child LiveView demonstrating context consumption from parent.
  """
  use Phoenix.LiveView

  use SharedAssigns.Consumer,
    contexts: [:theme, :user, :counter],
    pubsub: Demo.PubSub

  def mount(_params, _session, socket) do
    # Context subscription and initialization happens automatically via the Consumer macro
    {:ok, assign(socket, :local_message, "Hello from child LiveView!")}
  end

  def handle_event("update_message", %{"message" => message}, socket) do
    {:noreply, assign(socket, :local_message, message)}
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "border rounded-lg p-4",
      (@theme || "light") == "dark" && "bg-gray-800 border-gray-600" || "bg-white border-gray-300"
    ]}>
      <h3 class="font-bold text-lg mb-3">🧒 Child LiveView</h3>

      <div class="grid md:grid-cols-2 gap-4 mb-4">
        <div>
          <h4 class="font-semibold mb-2">Received Contexts:</h4>
          <ul class="space-y-1 text-sm">
            <li><span class="font-medium">Theme:</span> <%= @theme || "light" %></li>
            <li><span class="font-medium">User:</span> <%= Map.get(@user || %{}, :name, "Unknown") %> (<%= Map.get(@user || %{}, :role, "guest") %>)</li>
            <li><span class="font-medium">Counter:</span> <%= @counter || 0 %></li>
          </ul>
        </div>

        <div>
          <h4 class="font-semibold mb-2">Local State:</h4>
          <form phx-submit="update_message" class="space-y-2">
            <input
              type="text"
              name="message"
              value={@local_message}
              class={[
                "w-full px-3 py-1 border rounded-md text-sm",
                (@theme || "light") == "dark" && "bg-gray-700 border-gray-600 text-white" || "bg-white border-gray-300"
              ]}
            />
            <button
              type="submit"
              class="bg-purple-500 hover:bg-purple-600 text-white px-3 py-1 rounded-md text-sm"
            >
              Update
            </button>
          </form>
        </div>
      </div>

      <!-- Role-based content -->
      <%= if Map.get(@user || %{}, :role, "guest") == "admin" do %>
        <div class="bg-yellow-100 border border-yellow-400 rounded-md p-3 mb-3">
          <p class="text-yellow-800">👑 Admin Panel: You have administrative privileges!</p>
        </div>
      <% end %>

      <%= if Map.get(@user || %{}, :role, "guest") == "user" do %>
        <div class="bg-green-100 border border-green-400 rounded-md p-3 mb-3">
          <p class="text-green-800">👤 User Dashboard: Welcome, registered user!</p>
        </div>
      <% end %>

      <div class={[
        "text-xs p-2 rounded border",
        (@theme || "light") == "dark" && "bg-gray-700 border-gray-600" || "bg-gray-100 border-gray-200"
      ]}>
        📡 Consumes: <code>theme</code>, <code>user</code>, <code>counter</code>
        <br/>
        ✨ This child LiveView maintains its own local state while consuming parent contexts
      </div>
    </div>
    """
  end
end
