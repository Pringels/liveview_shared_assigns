defmodule SharedAssignsDemoWeb.UserCardComponent do
  use Phoenix.LiveComponent
  import SharedAssignsDemoWeb.CoreComponents
  use SharedAssigns.Consumer, contexts: []

  def update(%{subscribed_contexts: contexts} = assigns, socket) do
    # Dynamically set the subscribed contexts based on the prop
    socket =
      socket
      |> Phoenix.Component.assign(:subscribed_contexts, contexts)
      |> Phoenix.Component.assign(assigns)

    # Extract parent contexts manually since we're overriding update/2
    parent_contexts = Map.get(assigns, :__parent_contexts__, %{})

    # Inject only the contexts this component subscribes to
    context_assigns =
      contexts
      |> Enum.reduce(%{}, fn context_key, acc ->
        case Map.get(parent_contexts, context_key) do
          nil -> acc
          value -> Map.put(acc, context_key, value)
        end
      end)

    socket = Phoenix.Component.assign(socket, context_assigns)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="bg-white rounded-lg border border-gray-200 p-4 hover:shadow-md transition-shadow">
      <div class="flex items-center justify-between mb-3">
        <h3 class="font-semibold text-gray-900">{@user_name}</h3>
        <span class="text-xs px-2 py-1 bg-gray-100 text-gray-600 rounded-full">
          {length(@subscribed_contexts)} contexts
        </span>
      </div>

      <div class="space-y-2 text-sm">
        <%= if :theme in @subscribed_contexts do %>
          <div class="flex items-center space-x-2">
            <.icon name="hero-paint-brush" class="w-4 h-4 text-blue-500" />
            <span class="text-gray-600">Theme:</span>
            <span class="font-medium">{Map.get(assigns, :theme, "N/A")}</span>
          </div>
        <% end %>

        <%= if :user_role in @subscribed_contexts do %>
          <div class="flex items-center space-x-2">
            <.icon name="hero-user" class="w-4 h-4 text-green-500" />
            <span class="text-gray-600">Role:</span>
            <span class="font-medium capitalize">{Map.get(assigns, :user_role, "N/A")}</span>
          </div>
        <% end %>

        <%= if @subscribed_contexts == [] do %>
          <div class="flex items-center space-x-2 text-gray-400">
            <.icon name="hero-minus-circle" class="w-4 h-4" />
            <span class="italic">No context subscriptions</span>
          </div>
        <% end %>
      </div>

      <div class="mt-3 pt-3 border-t border-gray-100">
        <div class="text-xs text-gray-500">
          Subscribed to:
          <%= if @subscribed_contexts == [] do %>
            <span class="italic">none</span>
          <% else %>
            {Enum.join(@subscribed_contexts, ", ")}
          <% end %>
        </div>
        <div class="text-xs text-gray-400 mt-1">
          Re-renders only when subscribed contexts change
        </div>
      </div>
    </div>
    """
  end
end
