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
      Returns all available context keys for this provider.
      """
      @doc """\
      Returns the initial contexts configuration for this provider.\
      """\
      def __shared_assigns_contexts__ do\
        @shared_assigns_contexts\
      end
      def context_keys do
        Keyword.keys(@shared_assigns_contexts)
      end
    end
  end

  @doc """
  Helper function for putting context values from within the provider LiveView.
  """
  def put_context(socket, key, value) do
    SharedAssigns.put_context(socket, key, value)
  end

  @doc """
  Helper function for updating context values from within the provider LiveView.
  """
  def update_context(socket, key, fun) do
    SharedAssigns.update_context(socket, key, fun)
  end
end
