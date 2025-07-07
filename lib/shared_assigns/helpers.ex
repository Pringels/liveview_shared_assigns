defmodule SharedAssigns.Helpers do
  @moduledoc """
  Helper functions to make SharedAssigns usage seamless.
  """

  @doc """
  A helper function for preparing LiveView session with SharedAssigns contexts.

  This function automatically extracts the required contexts for a nested LiveView,
  allowing you to use it seamlessly with live_render.

  Usage:
      <%= live_render(@socket, MyChildLive, sa_live_session("child", MyChildLive, assigns)) %>
      <%= live_render(@socket, MyChildLive, sa_live_session("child", MyChildLive, assigns, %{"custom" => "session"})) %>
  """
  def sa_live_session(id, module, assigns, custom_session \\ %{}) do
    # Check if this is a SharedAssigns consumer
    if is_consumer?(module) do
      # Get the contexts this LiveView needs
      subscribed_contexts = get_subscribed_contexts(module)

      # Extract context values from the parent assigns
      context_values =
        subscribed_contexts
        |> Enum.map(fn key -> {Atom.to_string(key), Map.get(assigns, key)} end)
        |> Enum.into(%{})

      # Build the session with contexts and versions
      session =
        custom_session
        |> Map.put("parent_contexts", context_values)
        |> Map.put("parent_versions", Map.get(assigns, :__shared_assigns_versions__, %{}))

      [id: id, session: session]
    else
      # Regular LiveView, just pass through the id and custom session
      [id: id, session: custom_session]
    end
  end

  def is_consumer?(module) when is_atom(module) do
    try do
      Code.ensure_loaded!(module)
      function_exported?(module, :subscribed_contexts, 0)
    rescue
      _ -> false
    end
  end

  def is_consumer?(_), do: false

  def get_subscribed_contexts(module) do
    apply(module, :subscribed_contexts, [])
  end

  @doc """
  An ergonomic macro for rendering SharedAssigns-enabled LiveComponents.

  This macro automatically handles context injection. Components will be
  updated via send_update when contexts change.

  Usage:
      <.sa_live_component module={MyComponent} id="my-id" />
      <.sa_live_component module={MyComponent} id="my-id" class="custom-class" />
  """
  defmacro sa_live_component(opts) do
    quote do
      # Extract the options - they come as a keyword list in templates
      opts_list = unquote(opts)
      opts_map = opts_list |> Enum.into(%{})

      # Get the module to check if it's a consumer
      module = Map.get(opts_map, :module)

      if SharedAssigns.Helpers.is_consumer?(module) do
        # Get the contexts this component needs
        subscribed_contexts = SharedAssigns.Helpers.get_subscribed_contexts(module)

        # Get version information
        parent_versions = Map.get(var!(assigns), :__shared_assigns_versions__, %{})

        # Create a version key for cache busting
        version_key =
          subscribed_contexts
          |> Enum.map(fn ctx -> "#{ctx}:#{Map.get(parent_versions, ctx, 0)}" end)
          |> Enum.join("|")

        # Create final assigns with context values and version tracking
        final_assigns =
          opts_map
          |> Map.put(:__sa_version_key, version_key)

        # Add each context value as an assign
        final_assigns =
          Enum.reduce(subscribed_contexts, final_assigns, fn ctx, acc ->
            Map.put(acc, ctx, Map.get(var!(assigns), ctx))
          end)

        # Render with explicit assigns
        Phoenix.Component.live_component(final_assigns)
      else
        # Regular component
        Phoenix.Component.live_component(opts_map)
      end
    end
  end

  @doc """
  A helper function for seamlessly rendering LiveComponents with SharedAssigns context injection.

  This function automatically injects the required contexts into components that consume them,
  without requiring manual prop drilling. Context values are passed explicitly through assigns.

  Usage:
      component_assigns = sa_component(assigns, module: MyComponent, id: "my-id")
      <.live_component {component_assigns} />
  """
  def sa_component(parent_assigns, opts) do
    # Convert opts to a map and extract module
    opts_map = opts |> Enum.into(%{})
    module = Map.get(opts_map, :module)

    # Check if this is a SharedAssigns consumer
    if is_consumer?(module) do
      # Get the contexts this component needs
      subscribed_contexts = get_subscribed_contexts(module)

      # Extract context values from parent assigns
      context_assigns =
        subscribed_contexts
        |> Enum.map(fn key ->
          value = Map.get(parent_assigns, key)
          {key, value}
        end)
        |> Enum.into(%{})

      # Get version information from parent assigns
      parent_versions = Map.get(parent_assigns, :__shared_assigns_versions__, %{})

      version_assigns =
        subscribed_contexts
        |> Enum.map(fn key ->
          version = Map.get(parent_versions, key, 0)
          {:"__sa_version_#{key}", version}
        end)
        |> Enum.into(%{})

      # Create a combined version hash to force component updates when any context changes
      combined_version =
        subscribed_contexts
        |> Enum.map(fn key -> Map.get(parent_versions, key, 0) end)
        |> Enum.join("_")

      # Build the component assigns with contexts, versions, and combined version
      opts_map
      |> Map.merge(context_assigns)
      |> Map.merge(version_assigns)
      |> Map.put(:__sa_combined_version, combined_version)
    else
      # Regular component, just pass through the opts
      opts_map
    end
  end
end
