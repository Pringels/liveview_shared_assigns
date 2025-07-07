defmodule SharedAssigns.Provider do
  @moduledoc """
  Macro for LiveViews to declare themselves as context providers.

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
  """

  defmacro __using__(opts) do
    contexts = Keyword.get(opts, :contexts, [])

    quote do
      @before_compile SharedAssigns.Provider
      @shared_assigns_contexts unquote(contexts)

      # Import the seamless component helpers
      import SharedAssigns.Helpers, only: [sa_component: 1]
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
          super(params, session, socket)
        end

        unquote(generate_helper_functions())
      end
    else
      # If no mount/3 exists, create a default one
      quote do
        def mount(_params, _session, socket) do
          socket = SharedAssigns.initialize_contexts(socket, @shared_assigns_contexts)
          {:ok, socket}
        end

        unquote(generate_helper_functions())
      end
    end
  end

  defp generate_helper_functions do
    quote do
      @doc """
      Puts a context value, triggering re-renders for consumers of this context.
      """
      def put_context(socket, key, value) do
        SharedAssigns.put_context(socket, key, value)
      end

      @doc """
      Updates a context value using the given function.
      """
      def update_context(socket, key, fun) do
        SharedAssigns.update_context(socket, key, fun)
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
    end
  end
end
