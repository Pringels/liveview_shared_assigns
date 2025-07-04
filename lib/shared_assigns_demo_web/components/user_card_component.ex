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

    # Always inject theme for styling purposes even if not subscribed
    theme = Map.get(parent_contexts, :theme, "light")
    context_assigns = Map.put(context_assigns, :theme, theme)

    socket = Phoenix.Component.assign(socket, context_assigns)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class={[
      "rounded-lg border p-4 hover:shadow-md transition-all duration-300",
      @theme == "dark" && "bg-gray-800/80 border-gray-600 text-white",
      @theme == "light" && "bg-white border-gray-200 text-gray-900"
    ]}>
      <div class="flex items-center justify-between mb-3">
        <h3 class={[
          "font-semibold",
          @theme == "dark" && "text-white",
          @theme == "light" && "text-gray-900"
        ]}>
          {@user_name}
        </h3>
        <span class={[
          "text-xs px-2 py-1 rounded-full",
          @theme == "dark" && "bg-gray-700 text-gray-300",
          @theme == "light" && "bg-gray-100 text-gray-600"
        ]}>
          {length(@subscribed_contexts)} contexts
        </span>
      </div>

      <div class="space-y-2 text-sm">
        <%= if :theme in @subscribed_contexts do %>
          <div class="flex items-center space-x-2">
            <.icon name="hero-paint-brush" class="w-4 h-4 text-blue-500" />
            <span class={[
              @theme == "dark" && "text-gray-300",
              @theme == "light" && "text-gray-600"
            ]}>
              Theme:
            </span>
            <span class={[
              "font-medium",
              @theme == "dark" && "text-white",
              @theme == "light" && "text-gray-900"
            ]}>
              {Map.get(assigns, :theme, "N/A")}
            </span>
          </div>
        <% end %>

        <%= if :user_role in @subscribed_contexts do %>
          <div class="flex items-center space-x-2">
            <.icon name="hero-user" class="w-4 h-4 text-green-500" />
            <span class={[
              @theme == "dark" && "text-gray-300",
              @theme == "light" && "text-gray-600"
            ]}>
              Role:
            </span>
            <span class={[
              "font-medium capitalize",
              @theme == "dark" && "text-white",
              @theme == "light" && "text-gray-900"
            ]}>
              {Map.get(assigns, :user_role, "N/A")}
            </span>
          </div>
        <% end %>

        <%= if @subscribed_contexts == [] do %>
          <div class={[
            "flex items-center space-x-2",
            @theme == "dark" && "text-gray-500",
            @theme == "light" && "text-gray-400"
          ]}>
            <.icon name="hero-minus-circle" class="w-4 h-4" />
            <span class="italic">No context subscriptions</span>
          </div>
        <% end %>
      </div>

      <div class={[
        "mt-3 pt-3 border-t",
        @theme == "dark" && "border-gray-600",
        @theme == "light" && "border-gray-100"
      ]}>
        <div class={[
          "text-xs",
          @theme == "dark" && "text-gray-400",
          @theme == "light" && "text-gray-500"
        ]}>
          Subscribed to:
          <%= if @subscribed_contexts == [] do %>
            <span class="italic">none</span>
          <% else %>
            {Enum.join(@subscribed_contexts, ", ")}
          <% end %>
        </div>
        <div class={[
          "text-xs mt-1",
          @theme == "dark" && "text-gray-500",
          @theme == "light" && "text-gray-400"
        ]}>
          Re-renders only when subscribed contexts change
        </div>
      </div>
    </div>
    """
  end
end
