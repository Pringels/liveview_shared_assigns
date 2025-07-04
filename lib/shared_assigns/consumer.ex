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
        {:ok, socket}
      end

      def update(assigns, socket) do
        # Inject contexts from the parent socket
        socket =
          SharedAssigns.Consumer.inject_contexts(socket, assigns, @shared_assigns_consumer_keys)

        {:ok, Phoenix.Component.assign(socket, assigns)}
      end

      defoverridable mount: 1, update: 2
    end
  end

  @doc """
  Injects context values into component assigns from the parent socket.
  """
  def inject_contexts(socket, assigns, keys) do
    # The parent socket should have context data available via assigns
    parent_contexts = assigns[:__parent_contexts__] || %{}
    parent_versions = assigns[:__shared_assigns_versions__] || %{}

    # Build context assigns map for our needed keys
    context_assigns =
      Enum.reduce(keys, %{}, fn key, acc ->
        case Map.get(parent_contexts, key) do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end)

    # Build versions map for our keys
    version_assigns =
      Enum.reduce(keys, %{}, fn key, acc ->
        case Map.get(parent_versions, key) do
          nil -> acc
          version -> Map.put(acc, key, version)
        end
      end)

    socket
    |> Phoenix.Component.assign(context_assigns)
    |> Phoenix.Component.assign(:__consumer_context_versions__, version_assigns)
  end
end
