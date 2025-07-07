defmodule SharedAssigns.Component do
  @moduledoc """
  A seamless wrapper for live_component that automatically injects contexts.

  This eliminates the need to manually pass __parent_contexts__ and __shared_assigns_versions__.
  """

  @doc """
  Enhanced live_component that automatically passes contexts to SharedAssigns consumers.

  Usage:
      <SharedAssigns.Component.render
        module={MyComponent}
        id="my-component"
        other_prop="value"
      />
  """
  def render(assigns) do
    # Check if the target module is a SharedAssigns consumer
    if is_consumer?(assigns[:module]) do
      # Get the contexts this component subscribes to
      subscribed_contexts = get_subscribed_contexts(assigns[:module])

      # Extract only the needed contexts from the current socket
      socket = assigns[:__socket__] || raise "Socket not available in assigns"
      contexts = SharedAssigns.extract_contexts(socket, subscribed_contexts)
      versions = socket.assigns.__shared_assigns_versions__

      # Inject the contexts automatically
      enhanced_assigns =
        assigns
        |> Map.put(:__parent_contexts__, contexts)
        |> Map.put(:__shared_assigns_versions__, versions)

      Phoenix.Component.live_component(enhanced_assigns)
    else
      # Regular component, pass through unchanged
      Phoenix.Component.live_component(assigns)
    end
  end

  defp is_consumer?(module) when is_atom(module) do
    try do
      Code.ensure_loaded!(module)
      function_exported?(module, :subscribed_contexts, 0)
    rescue
      _ -> false
    end
  end

  defp is_consumer?(_), do: false

  defp get_subscribed_contexts(module) do
    try do
      apply(module, :subscribed_contexts, [])
    rescue
      _ -> []
    end
  end
end
