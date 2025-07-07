defmodule DemoWeb.Components.NestedContainerComponent do
  @moduledoc """
  A component that contains other components to demonstrate deep nesting
  with SharedAssigns context propagation.
  """
  use Phoenix.LiveComponent
  use SharedAssigns.Consumer, contexts: [:theme, :user, :counter]

  def render(assigns) do
    ~H"""
    <div class={[
      "p-4 border-2 border-dashed rounded-lg",
      (@theme || "light") == "dark" && "border-gray-600 bg-gray-800" || "border-gray-300 bg-gray-50"
    ]}>
      <h3 class="text-lg font-semibold mb-3">Nested Container</h3>
      <p class="text-sm mb-4">This component contains other SharedAssigns components:</p>

      <div class="space-y-4">
        <!-- Nested components using the ergonomic macro -->
        <.sa_live_component module={DemoWeb.Components.UserInfoComponent} id="nested-user-info" />
        <.sa_live_component module={DemoWeb.Components.CounterDisplayComponent} id="nested-counter-display" />
      </div>

      <p class="text-xs mt-4 text-gray-500">
        Theme from context: <%= @theme || "light" %>
      </p>
    </div>
    """
  end
end
