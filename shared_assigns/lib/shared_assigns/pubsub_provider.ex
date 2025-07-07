defmodule SharedAssigns.PubSubProvider do
  @moduledoc """
  Macro for LiveViews to declare themselves as context providers with PubSub broadcasting.

  This extends the basic Provider to broadcast context changes across LiveView processes,
  enabling nested LiveViews to subscribe to context changes from parent LiveViews.

  ## Usage

      defmodule MyAppWeb.PageLive do
        use MyAppWeb, :live_view
        use SharedAssigns.PubSubProvider,
          contexts: [
            theme: "light",
            user_role: "guest",
            notifications: []
          ],
          pubsub: MyApp.PubSub

        # Your LiveView implementation...
      end

  This automatically:
  - Initializes the contexts in `mount/3` 
  - Provides helper functions for updating contexts
  - Sets up version tracking for reactivity
  - Broadcasts context changes via PubSub for nested LiveViews to receive
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])

    pubsub =
      Keyword.get(opts, :pubsub) ||
        raise ArgumentError, "PubSubProvider requires a :pubsub option"

    quote do
      @before_compile SharedAssigns.PubSubProvider
      @shared_assigns_contexts unquote(contexts)
      @shared_assigns_pubsub unquote(pubsub)

      def mount(params, session, socket) do
        require Logger

        Logger.info(
          "PubSubProvider mounting with contexts: #{inspect(Keyword.keys(@shared_assigns_contexts))}"
        )

        socket = SharedAssigns.initialize_contexts(socket, @shared_assigns_contexts)

        # Subscribe to initial value requests for all our contexts
        Enum.each(Keyword.keys(@shared_assigns_contexts), fn key ->
          Phoenix.PubSub.subscribe(
            @shared_assigns_pubsub,
            "shared_assigns:#{key}:request_initial"
          )

          Logger.info("PubSubProvider subscribed to initial requests for: #{inspect(key)}")
        end)

        {:ok, socket}
      end

      def handle_info({:request_initial_value, key, requesting_pid}, socket) do
        require Logger

        Logger.info(
          "PubSubProvider received initial value request for: #{inspect(key)} from #{inspect(requesting_pid)}"
        )

        # Send the current value to the requesting process
        if key in Keyword.keys(@shared_assigns_contexts) do
          current_value = SharedAssigns.get_context(socket, key)
          current_version = SharedAssigns.get_context_version(socket, key)

          Logger.info(
            "PubSubProvider sending initial value: #{inspect(key)} = #{inspect(current_value)} (version: #{current_version})"
          )

          send(requesting_pid, {:initial_value, key, current_value, current_version})
        else
          Logger.warning("PubSubProvider received request for unknown context: #{inspect(key)}")
        end

        {:noreply, socket}
      end

      defoverridable mount: 3
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc """
      Puts a context value and broadcasts the change via PubSub.
      """
      def put_context(socket, key, value) do
        socket = SharedAssigns.put_context(socket, key, value)

        # Broadcast the context change
        SharedAssigns.PubSubProvider.broadcast_context_change(
          @shared_assigns_pubsub,
          key,
          value,
          SharedAssigns.get_context_version(socket, key)
        )

        socket
      end

      @doc """
      Updates a context value using the given function and broadcasts the change.
      """
      def update_context(socket, key, fun) do
        socket = SharedAssigns.update_context(socket, key, fun)

        # Broadcast the context change
        SharedAssigns.PubSubProvider.broadcast_context_change(
          @shared_assigns_pubsub,
          key,
          SharedAssigns.get_context(socket, key),
          SharedAssigns.get_context_version(socket, key)
        )

        socket
      end

      @doc """
      Gets the current value of a context.
      """
      def get_context(socket, key) do
        SharedAssigns.get_context(socket, key)
      end

      @doc """
      Returns the initial contexts configuration for this provider.
      """
      def __shared_assigns_contexts__ do
        @shared_assigns_contexts
      end

      @doc """
      Returns all available context keys for this provider.
      """
      def context_keys do
        Keyword.keys(@shared_assigns_contexts)
      end

      @doc """
      Returns the PubSub module for this provider.
      """
      def __shared_assigns_pubsub__ do
        @shared_assigns_pubsub
      end
    end
  end

  @doc """
  Broadcasts a context change to all subscribers.
  """
  def broadcast_context_change(pubsub, key, value, version) do
    require Logger

    Logger.info(
      "Broadcasting context change: #{inspect(key)} = #{inspect(value)} (version: #{version})"
    )

    result =
      Phoenix.PubSub.broadcast(pubsub, "shared_assigns:#{key}", {
        :context_changed,
        key,
        value,
        version
      })

    Logger.info("Broadcast result: #{inspect(result)}")
    result
  end
end
