defmodule SharedAssigns.PubSubConsumer do
  @moduledoc """
  Macro for nested LiveViews to subscribe to context changes via PubSub.

  This allows child LiveViews (running in separate processes) to subscribe to
  context changes from parent LiveViews that use PubSubProvider.

  ## Usage

      defmodule MyAppWeb.ChildLive do
        use MyAppWeb, :live_view
        use SharedAssigns.PubSubConsumer,
          contexts: [:theme, :user_role],
          pubsub: MyApp.PubSub

        # @theme and @user_role will be automatically available in assigns
        # LiveView only re-renders when these contexts change
      end

  This automatically:
  - Subscribes to PubSub topics for specified contexts
  - Injects context values into LiveView assigns
  - Handles PubSub messages to update contexts when they change
  - Provides granular reactivity across LiveView processes
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])

    pubsub =
      Keyword.get(opts, :pubsub) ||
        raise ArgumentError, "PubSubConsumer requires a :pubsub option"

    quote do
      @shared_assigns_consumer_contexts unquote(contexts)
      @shared_assigns_pubsub unquote(pubsub)

      def mount(params, session, socket) do
        require Logger

        Logger.info(
          "PubSubConsumer mounting and subscribing to contexts: #{inspect(@shared_assigns_consumer_contexts)}"
        )

        # Subscribe to PubSub topics for each context
        Enum.each(@shared_assigns_consumer_contexts, fn key ->
          Phoenix.PubSub.subscribe(@shared_assigns_pubsub, "shared_assigns:#{key}")
          Logger.info("PubSubConsumer subscribed to: shared_assigns:#{key}")
        end)

        # Initialize context values (will be updated when first messages arrive)
        context_assigns =
          @shared_assigns_consumer_contexts
          |> Enum.map(fn key -> {key, nil} end)
          |> Enum.into(%{})

        # Track versions for each context
        context_versions =
          @shared_assigns_consumer_contexts
          |> Enum.map(fn key -> {key, 0} end)
          |> Enum.into(%{})

        socket =
          socket
          |> Phoenix.Component.assign(:__subscribed_context_versions__, context_versions)
          |> then(fn sock ->
            Enum.reduce(context_assigns, sock, fn {key, value}, acc ->
              Phoenix.Component.assign(acc, key, value)
            end)
          end)

        # Request initial values from any providers after subscribing
        Enum.each(@shared_assigns_consumer_contexts, fn key ->
          Logger.info("PubSubConsumer requesting initial value for: #{inspect(key)}")

          Phoenix.PubSub.broadcast(
            @shared_assigns_pubsub,
            "shared_assigns:#{key}:request_initial",
            {
              :request_initial_value,
              key,
              self()
            }
          )

          Logger.info("PubSubConsumer broadcast initial request for: #{inspect(key)} complete")
        end)

        {:ok, socket}
      end

      def handle_info({:context_changed, key, value, version}, socket) do
        require Logger

        Logger.info(
          "PubSubConsumer received context change: #{inspect(key)} = #{inspect(value)} (version: #{version})"
        )

        # Only update if this context is one we subscribe to
        if key in @shared_assigns_consumer_contexts do
          current_version = Map.get(socket.assigns.__subscribed_context_versions__, key, 0)

          # Only update if the version is newer (prevents duplicate updates)
          if version > current_version do
            new_versions = Map.put(socket.assigns.__subscribed_context_versions__, key, version)

            socket =
              socket
              |> Phoenix.Component.assign(:__subscribed_context_versions__, new_versions)
              |> Phoenix.Component.assign(key, value)

            Logger.info("PubSubConsumer updated context: #{inspect(key)} = #{inspect(value)}")
            {:noreply, socket}
          else
            Logger.info("PubSubConsumer ignoring stale context change for: #{inspect(key)}")
            {:noreply, socket}
          end
        else
          Logger.warning("PubSubConsumer received unknown context: #{inspect(key)}")
          {:noreply, socket}
        end
      end

      def handle_info({:initial_value, key, value, version}, socket) do
        require Logger

        Logger.info(
          "PubSubConsumer received initial value: #{inspect(key)} = #{inspect(value)} (version: #{version})"
        )

        # Handle initial value responses from providers
        if key in @shared_assigns_consumer_contexts do
          new_versions = Map.put(socket.assigns.__subscribed_context_versions__, key, version)

          socket =
            socket
            |> Phoenix.Component.assign(:__subscribed_context_versions__, new_versions)
            |> Phoenix.Component.assign(key, value)

          Logger.info("PubSubConsumer set initial value: #{inspect(key)} = #{inspect(value)}")
          {:noreply, socket}
        else
          Logger.warning(
            "PubSubConsumer received initial value for unknown context: #{inspect(key)}"
          )

          {:noreply, socket}
        end
      end

      @doc """
      Returns the context keys this LiveView subscribes to.
      """
      def subscribed_contexts do
        @shared_assigns_consumer_contexts
      end

      @doc """
      Returns the PubSub module for this consumer.
      """
      def __shared_assigns_pubsub__ do
        @shared_assigns_pubsub
      end

      defoverridable mount: 3
    end
  end
end
