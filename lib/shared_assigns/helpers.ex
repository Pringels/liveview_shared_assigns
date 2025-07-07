defmodule SharedAssigns.Helpers do
  @moduledoc """
  Helper functions to make SharedAssigns usage seamless.
  """
  use Phoenix.Component

  @doc """
  A seamless component function that automatically handles SharedAssigns contexts.

  Usage:
      <.sa_component module={MyComponent} id="my-id" socket={@socket} />
  """
  def sa_component(assigns) do
    socket = assigns.socket

    if is_consumer?(assigns[:module]) do
      # Auto-inject contexts for SharedAssigns consumers
      subscribed_contexts = get_subscribed_contexts(assigns[:module])

      enhanced_assigns =
        assigns
        |> Map.put(
          :__parent_contexts__,
          SharedAssigns.extract_contexts(socket, subscribed_contexts)
        )
        |> Map.put(
          :__shared_assigns_versions__,
          Map.get(socket.assigns, :__shared_assigns_versions__, %{})
        )

      Phoenix.Component.live_component(enhanced_assigns)
    else
      # Regular component
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
    apply(module, :subscribed_contexts, [])
  end
end
