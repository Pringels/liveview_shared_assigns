defmodule SharedAssigns.Consumer do
  @moduledoc """
  Unified macro for LiveViews and LiveComponents to declare themselves as context consumers.

  ## Usage for LiveComponents

      defmodule MyAppWeb.HeaderComponent do
        use MyAppWeb, :live_component
        use SharedAssigns.Consumer, contexts: [:theme, :user_role]

        # @theme and @user_role will be automatically available in assigns
      end

  ## Usage for LiveViews (nested)

      defmodule MyAppWeb.ChildLive do
        use MyAppWeb, :live_view
        use SharedAssigns.Consumer,
          contexts: [:theme, :user_role],
          pubsub: Demo.PubSub

        # Contexts will be subscribed via PubSub and available in assigns
      end

  This automatically:
  - For components: Injects context values into component assigns
  - For LiveViews: Subscribes to context changes and handles updates
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])
    pubsub = Keyword.get(opts, :pubsub)

    if pubsub do
      # This is a LiveView that wants PubSub subscriptions
      quote do
        @before_compile SharedAssigns.Consumer
        @shared_assigns_consumer_contexts unquote(contexts)
        @shared_assigns_pubsub unquote(pubsub)
      end
    else
      # This is a LiveComponent (default behavior)
      quote do
        @shared_assigns_consumer_contexts unquote(contexts)

        # Import the helpers for nested components
        import SharedAssigns.Helpers, only: [sa_live_component: 1, sa_component: 2]

        def update(assigns, socket) do
          # Assign everything and let the contexts flow through
          {:ok, Phoenix.Component.assign(socket, assigns)}
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

  defmacro __before_compile__(env) do
    # Check if the module already defines mount/3
    has_mount = Module.defines?(env.module, {:mount, 3})

    if has_mount do
      # If mount/3 exists, wrap it with PubSub subscription setup
      quote do
        defoverridable mount: 3

        def mount(params, session, socket) do
          result = super(params, session, socket)

          case result do
            {:ok, socket} ->
              socket =
                SharedAssigns.setup_pubsub_consumer(
                  socket,
                  @shared_assigns_pubsub,
                  @shared_assigns_consumer_contexts,
                  session
                )

              {:ok, socket}

            other ->
              other
          end
        end

        def handle_info({:context_changed, key, value}, socket) do
          {:noreply, assign(socket, key, value)}
        end

        @doc """
        Returns the list of contexts this LiveView subscribes to.
        """
        def subscribed_contexts do
          @shared_assigns_consumer_contexts
        end
      end
    else
      # If no mount/3 exists, create a default one
      quote do
        def mount(params, session, socket) do
          socket =
            SharedAssigns.setup_pubsub_consumer(
              socket,
              @shared_assigns_pubsub,
              @shared_assigns_consumer_contexts,
              session
            )

          {:ok, socket}
        end

        def handle_info({:context_changed, key, value}, socket) do
          {:noreply, assign(socket, key, value)}
        end

        @doc """
        Returns the list of contexts this LiveView subscribes to.
        """
        def subscribed_contexts do
          @shared_assigns_consumer_contexts
        end
      end
    end
  end
end
