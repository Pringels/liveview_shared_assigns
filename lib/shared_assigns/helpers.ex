defmodule SharedAssigns.Helpers do
  @moduledoc """
  Helper functions to make SharedAssigns usage seamless.
  """

  @doc """
  A drop-in replacement for live_component that automatically handles SharedAssigns contexts.

  Instead of:
      <.live_component module={MyComponent} id="my-id"
        __parent_contexts__={extract_contexts(@socket, [:theme])}
        __shared_assigns_versions__={@__shared_assigns_versions__} />

  Just use:
      <SharedAssigns.Helpers.component module={MyComponent} id="my-id" />

  Or even better, import this module and use:
      <.sa_component module={MyComponent} id="my-id" />
  """
  def component(assigns) do
    if is_consumer?(assigns[:module]) do
      # Auto-inject contexts for SharedAssigns consumers
      subscribed_contexts = get_subscribed_contexts(assigns[:module])
      socket = get_socket_from_assigns(assigns)

      enhanced_assigns =
        assigns
        |> Map.put(:__parent_contexts__, extract_contexts(socket, subscribed_contexts))
        |> Map.put(:__shared_assigns_versions__, get_versions(socket))

      Phoenix.Component.live_component(enhanced_assigns)
    else
      # Regular component
      Phoenix.Component.live_component(assigns)
    end
  end

  # Shorter alias
  def sa_component(assigns), do: component(assigns)

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

  defp get_socket_from_assigns(assigns) do
    # In LiveView templates, socket is available as @socket
    # In component templates, it might be passed differently
    assigns[:socket] || assigns[:__socket__] ||
      raise ArgumentError,
            "Socket not available in assigns. Make sure to call this from a LiveView template."
  end

  defp extract_contexts(socket, keys) do
    contexts = socket.assigns.__shared_assigns_contexts__

    keys
    |> Enum.map(fn key -> {key, Map.get(contexts, key)} end)
    |> Enum.into(%{})
  end

  defp get_versions(socket) do
    Map.get(socket.assigns, :__shared_assigns_versions__, %{})
  end
end
