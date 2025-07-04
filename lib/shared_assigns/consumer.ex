defmodule SharedAssigns.Consumer do
  @moduledoc """
  Macro for LiveComponents to declare needed context keys with automatic injection.

  ## Usage

      defmodule MyAppWeb.HeaderComponent do
        use Phoenix.LiveComponent
        use SharedAssigns.Consumer, keys: [:theme, :user_role]

        def render(assigns) do
          ~H\"""
          <header class={"theme-\#{@theme} role-\#{@user_role}"}>
            <h1>My App</h1>
          </header>
          \"""
        end
      end

  This automatically:
  - Injects context values into assigns during mount
  - Sets up version tracking for granular re-renders
  - Only re-renders when consumed context keys change
  """

  defmacro __using__(opts) do
    keys = Keyword.get(opts, :keys, [])

    quote do
      @shared_assigns_consumer_keys unquote(keys)

      def mount(socket) do
        socket = SharedAssigns.Consumer.inject_contexts(socket, @shared_assigns_consumer_keys)
        super(socket)
      end

      def update(assigns, socket) do
        # Check if any of our context versions have changed
        socket =
          SharedAssigns.Consumer.maybe_update_contexts(
            socket,
            assigns,
            @shared_assigns_consumer_keys
          )

        super(assigns, socket)
      end

      defoverridable mount: 1, update: 2
    end
  end

  @doc """
  Injects context values into component assigns during mount.
  """
  def inject_contexts(socket, keys) do
    contexts = get_contexts_from_parent(socket, keys)
    versions = get_versions_from_parent(socket, keys)

    socket
    |> Phoenix.Component.assign(contexts)
    |> Phoenix.Component.assign(:__consumer_context_versions__, versions)
  end

  @doc """
  Updates context values in component if versions have changed.
  """
  def maybe_update_contexts(socket, assigns, keys) do
    current_versions = socket.assigns[:__consumer_context_versions__] || %{}
    parent_versions = get_versions_from_parent(socket, keys)

    # Check if any versions have changed
    changed_keys =
      Enum.filter(keys, fn key ->
        current_versions[key] != parent_versions[key]
      end)

    if changed_keys != [] do
      # Update contexts for changed keys
      updated_contexts = get_contexts_from_parent(socket, changed_keys)

      socket
      |> Phoenix.Component.assign(updated_contexts)
      |> Phoenix.Component.assign(:__consumer_context_versions__, parent_versions)
    else
      socket
    end
  end

  defp get_contexts_from_parent(socket, keys) do
    # Try to get contexts from parent LiveView via assigns or private
    parent_contexts =
      case socket.assigns[:__shared_assigns_versions__] do
        nil ->
          %{}

        _versions ->
          # We're in a LiveView context, get from private
          socket.private[:__shared_assigns_contexts__] || %{}
      end

    # Build context assigns map
    Enum.reduce(keys, %{}, fn key, acc ->
      case Map.get(parent_contexts, key) do
        nil -> acc
        value -> Map.put(acc, key, value)
      end
    end)
  end

  defp get_versions_from_parent(socket, keys) do
    parent_versions = socket.assigns[:__shared_assigns_versions__] || %{}

    # Build versions map for our keys
    Enum.reduce(keys, %{}, fn key, acc ->
      case Map.get(parent_versions, key) do
        nil -> acc
        version -> Map.put(acc, key, version)
      end
    end)
  end
end
