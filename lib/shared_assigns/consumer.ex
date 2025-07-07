defmodule SharedAssigns.Consumer do
  @moduledoc """
  Macro for LiveComponents to declare themselves as context consumers.

  ## Usage

      defmodule MyAppWeb.HeaderComponent do
        use MyAppWeb, :live_component
        use SharedAssigns.Consumer, contexts: [:theme, :user_role]

        # @theme and @user_role will be automatically available in assigns
      end

  This automatically:
  - Subscribes the component to specific context changes
  - Injects context values into component assigns
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])

    quote do
      @shared_assigns_consumer_contexts unquote(contexts)

      def update(assigns, socket) do
        # Extract parent contexts from assigns passed by the sa_component helper
        parent_contexts = Map.get(assigns, :__parent_contexts__, %{})

        # Assign each subscribed context to the socket
        socket_with_contexts =
          Enum.reduce(@shared_assigns_consumer_contexts, socket, fn key, acc ->
            value = Map.get(parent_contexts, key)
            Phoenix.Component.assign(acc, key, value)
          end)

        # Filter out reserved assigns and internal assigns
        filtered_assigns =
          assigns
          |> Map.drop([:socket, :__parent_contexts__, :__shared_assigns_versions__])

        # Also assign all other props
        final_socket = Phoenix.Component.assign(socket_with_contexts, filtered_assigns)

        {:ok, final_socket}
      end

      @doc """
      Returns the list of contexts this component subscribes to.
      """
      def subscribed_contexts do
        @shared_assigns_consumer_contexts
      end
    end
  end
end
