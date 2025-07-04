defmodule SharedAssigns.Consumer do
  @moduledoc """
  Macro for LiveComponents to declare themselves as context consumers.

  ## Usage

      defmodule MyAppWeb.HeaderComponent do
        use MyAppWeb, :live_component
        use SharedAssigns.Consumer, contexts: [:theme, :user_role]
        
        # @theme and @user_role will be automatically available in assigns
        # Component only re-renders when these contexts change
      end

  This automatically:
  - Subscribes the component to specific context changes
  - Injects context values into component assigns
  - Only triggers re-renders when subscribed contexts change
  - Provides granular reactivity without prop drilling
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])

    quote do
      @shared_assigns_consumer_contexts unquote(contexts)

      def mount(socket) do
        # Extract parent contexts from assigns passed by the LiveView
        parent_contexts = Map.get(socket.assigns, :__parent_contexts__, %{})

        # Inject subscribed context values into component assigns
        context_assigns =
          @shared_assigns_consumer_contexts
          |> Enum.map(fn key -> {key, Map.get(parent_contexts, key)} end)
          |> Enum.into(%{})

        socket =
          Enum.reduce(context_assigns, socket, fn {key, value}, acc ->
            Phoenix.Component.assign(acc, key, value)
          end)

        {:ok, socket}
      end

      def update(_assigns, socket) do
        # Extract parent contexts and versions for reactivity check
        parent_contexts = Map.get(socket.assigns, :__parent_contexts__, %{})
        parent_versions = Map.get(socket.assigns, :__shared_assigns_versions__, %{})

        # Get last known versions for our subscribed contexts
        last_versions = Map.get(socket.assigns, :__last_context_versions__, %{})

        # Check if any of our subscribed contexts have changed
        contexts_changed =
          Enum.any?(@shared_assigns_consumer_contexts, fn key ->
            current_version = Map.get(parent_versions, key, 0)
            last_version = Map.get(last_versions, key, 0)
            current_version > last_version
          end)

        if contexts_changed do
          # Update context values in assigns
          context_assigns =
            @shared_assigns_consumer_contexts
            |> Enum.map(fn key -> {key, Map.get(parent_contexts, key)} end)
            |> Enum.into(%{})

          # Update last known versions
          new_last_versions =
            @shared_assigns_consumer_contexts
            |> Enum.map(fn key -> {key, Map.get(parent_versions, key, 0)} end)
            |> Enum.into(%{})

          socket =
            socket
            |> Phoenix.Component.assign(:__last_context_versions__, new_last_versions)
            |> then(fn sock ->
              Enum.reduce(context_assigns, sock, fn {key, value}, acc ->
                Phoenix.Component.assign(acc, key, value)
              end)
            end)

          {:ok, socket}
        else
          {:ok, socket}
        end
      end

      @doc """
      Returns the context keys this component subscribes to.
      """
      def subscribed_contexts do
        @shared_assigns_consumer_contexts
      end
    end
  end
end
