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
      import SharedAssigns.Provider, only: [put_context: 3, update_context: 4]

      @before_compile SharedAssigns.Provider
      @shared_assigns_contexts unquote(contexts)

      def mount(params, session, socket) do
        socket = SharedAssigns.initialize_contexts(socket, @shared_assigns_contexts)
        {:ok, socket}
      end

      defoverridable mount: 3
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      @doc """
      Puts a context value, triggering re-renders for consumers of this context.
      """
      def put_context(socket, key, value) do
        SharedAssigns.put(socket, key, value)
      end

      @doc """
      Updates a context value using the given function.
      """
      def update_context(socket, key, default, fun) do
        SharedAssigns.update(socket, key, default, fun)
      end

      @doc """
      Gets the current value of a context.
      """
      def get_context(socket, key, default \\ nil) do
        SharedAssigns.get(socket, key, default)
      end

      @doc """
      Returns all available context keys for this provider.
      """
      def context_keys do
        Keyword.keys(@shared_assigns_contexts)
      end
    end
  end

  @doc """
  Helper function for putting context values from within the provider LiveView.
  """
  def put_context(socket, key, value) do
    SharedAssigns.put(socket, key, value)
  end

  @doc """
  Helper function for updating context values from within the provider LiveView.
  """
  def update_context(socket, key, default, fun) do
    SharedAssigns.update(socket, key, default, fun)
  end
end
