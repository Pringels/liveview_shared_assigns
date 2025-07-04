defmodule SharedAssignsDemoWeb.ChildLive do
  use SharedAssignsDemoWeb, :live_view

  use SharedAssigns.PubSubConsumer,
    contexts: [:theme, :user_role],
    pubsub: SharedAssignsDemo.PubSub

  def render(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div class="p-4 bg-white rounded-lg border border-purple-200">
          <h3 class="font-medium text-gray-700 mb-2">Theme Context</h3>
          <p class="text-lg font-semibold text-blue-600" id="child-theme">
            {@theme || "Not received yet"}
          </p>
          <p class="text-xs text-gray-500 mt-1">
            Via PubSub from parent LiveView
          </p>
        </div>
        <div class="p-4 bg-white rounded-lg border border-purple-200">
          <h3 class="font-medium text-gray-700 mb-2">User Role Context</h3>
          <p class="text-lg font-semibold text-green-600" id="child-role">
            {@user_role || "Not received yet"}
          </p>
          <p class="text-xs text-gray-500 mt-1">
            Via PubSub from parent LiveView
          </p>
        </div>
      </div>

      <div class="p-4 bg-green-50 rounded-lg border border-green-200">
        <h4 class="font-semibold text-green-900 mb-2">🔄 Real-time Updates</h4>
        <p class="text-sm text-green-800">
          This nested LiveView automatically updates when you change the theme or user role above.
          No props were passed down - contexts flow via PubSub across separate processes!
        </p>
      </div>

      <div class="p-4 bg-blue-50 rounded-lg border border-blue-200">
        <h4 class="font-semibold text-blue-900 mb-2">⚡ How it works:</h4>
        <ul class="text-sm text-blue-800 space-y-1">
          <li>• This LiveView runs in a separate process from the parent</li>
          <li>• It subscribes to theme and user_role contexts via PubSub on mount</li>
          <li>• When parent updates contexts, this LiveView receives messages and re-renders</li>
          <li>• Zero prop drilling - contexts flow seamlessly across process boundaries</li>
          <li>• Each LiveView maintains independent state and lifecycle</li>
        </ul>
      </div>
    </div>
    """
  end
end
