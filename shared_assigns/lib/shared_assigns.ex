defmodule SharedAssigns do
  @moduledoc """
  SharedAssigns provides a React Context-like system for Phoenix LiveView
  to eliminate prop drilling by allowing components to subscribe to specific
  context values and automatically re-render when those contexts change.

  ## Usage

  ### In a LiveView (Provider)
  ```elixir
  defmodule MyAppWeb.PageLive do
    use MyAppWeb, :live_view
    use SharedAssigns.Provider, contexts: [theme: "light", user_role: "guest"]
    
    def handle_event("toggle_theme", _params, socket) do
      new_theme = if get_context(socket, :theme) == "light", do: "dark", else: "light"
      {:noreply, put_context(socket, :theme, new_theme)}
    end
  end
  ```

  ### In a LiveComponent (Consumer)
  ```elixir
  defmodule MyAppWeb.HeaderComponent do
    use MyAppWeb, :live_component
    use SharedAssigns.Consumer, contexts: [:theme]
    
    # @theme will be automatically available in assigns
  end
  ```

  ## Context Management

  Contexts are stored in the LiveView socket and tracked with version numbers
  to enable granular reactivity. Only components that subscribe to changed
  contexts will re-render.
  """

  import Phoenix.Component, only: [assign: 3]

  @doc """
  Initializes the SharedAssigns context storage in a LiveView socket.
  This is typically called automatically by the Provider macro.

  ## Examples

      def mount(_params, _session, socket) do
        socket = SharedAssigns.initialize_contexts(socket, theme: "light", user_role: "guest")
        {:ok, socket}
      end
  """
  def initialize_contexts(socket, initial_contexts \\ []) do
    contexts = Enum.into(initial_contexts, %{})
    versions = contexts |> Enum.map(fn {key, _value} -> {key, 1} end) |> Enum.into(%{})

    socket
    |> assign(:__shared_assigns_contexts__, contexts)
    |> assign(:__shared_assigns_versions__, versions)
  end

  @doc """
  Sets a context value and increments its version for reactivity tracking.

  ## Examples

      socket = SharedAssigns.put_context(socket, :theme, "dark")
  """
  def put_context(socket, key, value) do
    contexts = Map.put(socket.assigns.__shared_assigns_contexts__, key, value)

    current_version = Map.get(socket.assigns.__shared_assigns_versions__, key, 0)
    versions = Map.put(socket.assigns.__shared_assigns_versions__, key, current_version + 1)

    socket
    |> assign(:__shared_assigns_contexts__, contexts)
    |> assign(:__shared_assigns_versions__, versions)
  end

  @doc """
  Updates a context value using a function and increments its version.

  ## Examples

      socket = SharedAssigns.update_context(socket, :count, &(&1 + 1))
  """
  def update_context(socket, key, fun) do
    current_value = Map.get(socket.assigns.__shared_assigns_contexts__, key)
    new_value = fun.(current_value)
    put_context(socket, key, new_value)
  end

  @doc """
  Gets a context value from the socket.

  ## Examples

      theme = SharedAssigns.get_context(socket, :theme)
  """
  def get_context(socket, key) do
    Map.get(socket.assigns.__shared_assigns_contexts__, key)
  end

  @doc """
  Gets the current version of a context for reactivity tracking.

  ## Examples

      version = SharedAssigns.get_context_version(socket, :theme)
  """
  def get_context_version(socket, key) do
    Map.get(socket.assigns.__shared_assigns_versions__, key, 0)
  end

  @doc """
  Checks if any of the given context keys have been updated since the last check.
  This is used internally by Consumer components to determine if they need to re-render.

  ## Examples

      changed? = SharedAssigns.contexts_changed?(socket, [:theme, :user_role], last_versions)
  """
  def contexts_changed?(socket, context_keys, last_versions \\ %{}) do
    Enum.any?(context_keys, fn key ->
      current_version = get_context_version(socket, key)
      last_version = Map.get(last_versions, key, 0)
      current_version > last_version
    end)
  end

  @doc """
  Extracts context values for the given keys into a map.
  Used by Consumer components to inject context values into their assigns.

  ## Examples

      contexts = SharedAssigns.extract_contexts(socket, [:theme, :user_role])
      # Returns: %{theme: "dark", user_role: "admin"}
  """
  def extract_contexts(socket, context_keys) do
    context_keys
    |> Enum.map(fn key -> {key, get_context(socket, key)} end)
    |> Enum.into(%{})
  end
end
