defmodule SharedAssigns.Consumer do
  @moduledoc """
  Macro for LiveComponents to declare themselves as context consumers.

  ## Usage

      defmodule MyAppWeb.HeaderComponent do
        use Phoenix.LiveComponent
        use SharedAssigns.Consumer, contexts: [:theme]

        # Your component implementation...
        # @theme will be automatically available in assigns
      end

  This automatically:
  - Subscribes to the specified contexts
  - Injects context values into component assigns
  - Only re-renders when subscribed contexts change
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])

    quote do
      @shared_assigns_subscribed_contexts unquote(contexts)

      def mount(socket) do
        {:ok, socket}
      end

      def update(assigns, socket) do
        # Extract parent contexts and versions
        parent_contexts = Map.get(assigns, :__parent_contexts__, %{})
        versions = Map.get(assigns, :__shared_assigns_versions__, %{})

        # Inject subscribed context values into assigns
        context_assigns =
          @shared_assigns_subscribed_contexts
          |> Enum.reduce(%{}, fn context_key, acc ->
            case Map.get(parent_contexts, context_key) do
              nil -> acc
              value -> Map.put(acc, context_key, value)
            end
          end)

        # Merge all assigns together
        socket =
          socket
          |> Phoenix.Component.assign(assigns)
          |> Phoenix.Component.assign(context_assigns)

        {:ok, socket}
      end

      defoverridable update: 2

      @doc """
      Returns the contexts this component subscribes to.
      """
      def subscribed_contexts do
        @shared_assigns_subscribed_contexts
      end

      @doc """
      Checks if this component should re-render based on context version changes.
      """
      def should_update_for_context?(context_key) do
        context_key in @shared_assigns_subscribed_contexts
      end
    end
  end

  @doc """
  Helper function to get a context value from a LiveComponent socket.
  Falls back to parent context if not found in socket assigns.
  """
  def get_context(socket_or_assigns, key, default \\ nil)

  def get_context(%Phoenix.LiveView.Socket{assigns: assigns}, key, default) do
    get_context(assigns, key, default)
  end

  def get_context(%{} = assigns, key, default) do
    case Map.get(assigns, key) do
      nil ->
        # Fall back to parent contexts
        parent_contexts = Map.get(assigns, :__parent_contexts__, %{})
        Map.get(parent_contexts, key, default)

      value ->
        value
    end
  end
end
