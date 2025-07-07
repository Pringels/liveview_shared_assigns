defmodule SharedAssigns.Provider do
  @moduledoc """
  Unified macro for LiveViews to declare themselves as context providers.

  ## Usage

      defmodule MyAppWeb.PageLive do
        use MyAppWeb, :live_view
        use SharedAssigns.Provider,
          contexts: [
            theme: "light",
            user_role: "guest",
            notifications: []
          ]

        # Your LiveView implementation...
      end

  This automatically:
  - Initializes the contexts in `mount/3`
  - Provides helper functions for updating contexts
  - Sets up version tracking for reactivity
  - Handles PubSub for nested LiveViews automatically
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])
    pubsub = Keyword.get(opts, :pubsub)

    quote do
      @before_compile SharedAssigns.Provider
      @shared_assigns_contexts unquote(contexts)
      @shared_assigns_pubsub unquote(pubsub)

      # Import the seamless component and LiveView helpers
      import SharedAssigns.Helpers,
        only: [sa_component: 2, sa_live_component: 1, sa_live_session: 3, sa_live_session: 4]
    end
  end

  defmacro __before_compile__(env) do
    # Check if the module already defines mount/3
    has_mount = Module.defines?(env.module, {:mount, 3})

    if has_mount do
      # If mount/3 exists, wrap it with context initialization
      quote do
        defoverridable mount: 3

        def mount(params, session, socket) do
          socket = SharedAssigns.initialize_contexts(socket, @shared_assigns_contexts)

          # Set up PubSub if configured
          socket =
            if @shared_assigns_pubsub do
              SharedAssigns.setup_pubsub_provider(
                socket,
                @shared_assigns_pubsub,
                @shared_assigns_contexts
              )
            else
              socket
            end

          super(params, session, socket)
        end

        unquote(generate_helper_functions())

        # Handle context requests from consumers
        def handle_info({:request_contexts, requested_keys, consumer_pid}, socket) do
          # Send current context values to the requesting consumer
          Enum.each(requested_keys, fn key ->
            value = get_context(socket, key)

            if value != nil do
              send(consumer_pid, {:context_changed, key, value})
            end
          end)

          {:noreply, socket}
        end
      end
    else
      # If no mount/3 exists, create a default one
      quote do
        def mount(_params, _session, socket) do
          socket = SharedAssigns.initialize_contexts(socket, @shared_assigns_contexts)

          # Set up PubSub if configured
          socket =
            if @shared_assigns_pubsub do
              SharedAssigns.setup_pubsub_provider(
                socket,
                @shared_assigns_pubsub,
                @shared_assigns_contexts
              )
            else
              socket
            end

          {:ok, socket}
        end

        unquote(generate_helper_functions())

        # Handle context requests from consumers
        def handle_info({:request_contexts, requested_keys, consumer_pid}, socket) do
          # Send current context values to the requesting consumer
          Enum.each(requested_keys, fn key ->
            value = get_context(socket, key)

            if value != nil do
              send(consumer_pid, {:context_changed, key, value})
            end
          end)

          {:noreply, socket}
        end
      end
    end
  end

  defp generate_helper_functions do
    quote do
      @doc """
      Puts a context value, triggering re-renders for consumers of this context.
      """
      def put_context(socket, key, value) do
        socket = SharedAssigns.put_context(socket, key, value)

        # Broadcast via PubSub if configured
        if @shared_assigns_pubsub do
          SharedAssigns.broadcast_context_change(@shared_assigns_pubsub, key, value)
        end

        # Send updates to all LiveComponents that consume this context
        send_component_updates(socket, key, value)

        socket
      end

      @doc """
      Updates a context value using the provided function.
      """
      def update_context(socket, key, update_fn) do
        current_value = get_context(socket, key)
        new_value = update_fn.(current_value)
        put_context(socket, key, new_value)
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

      # Private function to send updates to consuming components
      defp send_component_updates(socket, context_key, value) do
        IO.inspect(
          %{
            sending_updates_for: context_key,
            new_value: value
          },
          label: "Provider sending component updates"
        )

        # Send updates to well-known component IDs based on naming convention
        send_update_to_known_components(socket, context_key)
      end

      defp send_update_to_known_components(socket, context_key) do
        # List of component modules and their typical IDs that might consume contexts
        known_components = [
          {DemoWeb.Components.UserInfoComponent, ["user-info", "nested-user-info"]},
          {DemoWeb.Components.CounterDisplayComponent,
           ["counter-display", "nested-counter-display"]},
          {DemoWeb.Components.HeaderComponent, ["header"]},
          {DemoWeb.Components.NestedContainerComponent, ["nested-container"]}
        ]

        Enum.each(known_components, fn {component_module, component_ids} ->
          if is_consumer_of_context?(component_module, context_key) do
            subscribed_contexts = get_subscribed_contexts_for_module(component_module)

            Enum.each(component_ids, fn component_id ->
              component_assigns = build_component_assigns(socket, subscribed_contexts)
              component_assigns = Map.put(component_assigns, :id, component_id)

              IO.inspect(
                %{
                  sending_to: component_module,
                  component_id: component_id,
                  assigns: component_assigns
                },
                label: "Sending update"
              )

              # Send update to the component
              Phoenix.LiveView.send_update(component_module, component_assigns)
            end)
          end
        end)
      end

      defp is_consumer_of_context?(component_module, context_key) do
        if Code.ensure_loaded?(component_module) and
             function_exported?(component_module, :subscribed_contexts, 0) do
          subscribed_contexts = apply(component_module, :subscribed_contexts, [])
          context_key in subscribed_contexts
        else
          false
        end
      end

      defp get_subscribed_contexts_for_module(component_module) do
        if Code.ensure_loaded?(component_module) and
             function_exported?(component_module, :subscribed_contexts, 0) do
          apply(component_module, :subscribed_contexts, [])
        else
          []
        end
      end

      defp build_component_assigns(socket, subscribed_contexts) do
        # Get current context values
        context_assigns =
          subscribed_contexts
          |> Enum.map(fn key -> {key, get_context(socket, key)} end)
          |> Enum.into(%{})

        # Get version information
        versions = Map.get(socket.assigns, :__shared_assigns_versions__, %{})

        version_assigns =
          subscribed_contexts
          |> Enum.map(fn key -> {:"__sa_version_#{key}", Map.get(versions, key, 0)} end)
          |> Enum.into(%{})

        # Combine assigns
        Map.merge(context_assigns, version_assigns)
      end
    end
  end
end
