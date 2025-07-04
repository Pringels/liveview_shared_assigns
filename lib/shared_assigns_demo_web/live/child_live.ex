defmodule SharedAssignsDemoWeb.ChildLive do
  use SharedAssignsDemoWeb, :live_view

  use SharedAssigns.PubSubConsumer,
    contexts: [:theme, :user_role],
    pubsub: SharedAssignsDemo.PubSub

  def render(assigns) do
    ~H"""
    <SharedAssignsDemoWeb.Layouts.app flash={@flash}>
      <div class="min-h-screen bg-gradient-to-br from-purple-50 to-pink-100">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div class="bg-white rounded-xl shadow-lg p-8">
            <div class="mb-6">
              <h1 class="text-3xl font-bold text-gray-900 mb-2">Child LiveView Demo</h1>
              <p class="text-gray-600">
                This is a separate LiveView process that subscribes to contexts from the parent.
              </p>
            </div>

            <div class="space-y-6">
              <div class="p-6 bg-blue-50 rounded-lg">
                <h2 class="text-xl font-semibold text-blue-900 mb-4">Context Values from Parent</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div class="p-4 bg-white rounded border">
                    <h3 class="font-medium text-gray-700 mb-2">Theme Context</h3>
                    <p class="text-lg font-semibold text-blue-600" id="child-theme">
                      {@theme || "Not set"}
                    </p>
                  </div>
                  <div class="p-4 bg-white rounded border">
                    <h3 class="font-medium text-gray-700 mb-2">User Role Context</h3>
                    <p class="text-lg font-semibold text-green-600" id="child-role">
                      {@user_role || "Not set"}
                    </p>
                  </div>
                </div>
              </div>

              <div class="p-6 bg-green-50 rounded-lg">
                <h3 class="font-semibold text-green-900 mb-2">How it works:</h3>
                <ul class="text-sm text-green-800 space-y-1">
                  <li>• This LiveView runs in a separate process from the parent</li>
                  <li>• It subscribes to theme and user_role contexts via PubSub</li>
                  <li>• When parent updates contexts, this LiveView automatically re-renders</li>
                  <li>• Zero prop drilling - contexts flow across process boundaries</li>
                </ul>
              </div>

              <div class="text-center">
                <.link
                  navigate={~p"/"}
                  class="inline-flex items-center px-6 py-3 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition-colors"
                >
                  ← Back to Parent LiveView
                </.link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </SharedAssignsDemoWeb.Layouts.app>
    """
  end
end
