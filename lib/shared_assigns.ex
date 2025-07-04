defmodule SharedAssigns do
  @moduledoc """
  SharedAssigns provides a React Context-like API for Phoenix LiveView to eliminate prop drilling.

  ## Core Concepts

  - **Provider**: A LiveView that declares initial context using `use SharedAssigns.Provider`
  - **Consumer**: Components that declare needed context keys using `use SharedAssigns.Consumer`
  - **Reactivity**: Granular re-renders using version tracking in assigns

  ## Example

      # Provider LiveView
      defmodule MyAppWeb.PageLive do
        use MyAppWeb, :live_view
        use SharedAssigns.Provider,
          contexts: [
            theme: "light",
            user_role: "guest"
          ]

        def handle_event("toggle_theme", _, socket) do
          new_theme = if SharedAssigns.get(socket, :theme) == "light", do: "dark", else: "light"
          socket = SharedAssigns.put(socket, :theme, new_theme)
          {:noreply, socket}
        end
      end

      # Consumer Component
      defmodule MyAppWeb.HeaderComponent do
        use Phoenix.LiveComponent
        use SharedAssigns.Consumer, keys: [:theme]

        def render(assigns) do
          ~H\"""
          <header class={"theme-\#{@theme}"}>
            <h1>My App</h1>
          </header>
          \"""
        end
      end
  """

  @doc """
  Gets a context value from the socket.

  ## Examples

      theme = SharedAssigns.get(socket, :theme)
      user_role = SharedAssigns.get(socket, :user_role, "guest")
  """
  def get(socket, key, default \\ nil) do
    contexts = socket.private[:__shared_assigns_contexts__] || %{}
    Map.get(contexts, key, default)
  end

  @doc """
  Puts a context value into the socket, updating both the private context storage
  and the version tracking in assigns to trigger reactivity.

  ## Examples

      socket = SharedAssigns.put(socket, :theme, "dark")
      socket = SharedAssigns.put(socket, :user_role, "admin")
  """
  def put(socket, key, value) do
    contexts = socket.private[:__shared_assigns_contexts__] || %{}
    versions = socket.assigns[:__shared_assigns_versions__] || %{}

    new_contexts = Map.put(contexts, key, value)
    new_versions = Map.put(versions, key, (versions[key] || 0) + 1)

    socket
    |> Phoenix.LiveView.put_private(:__shared_assigns_contexts__, new_contexts)
    |> Phoenix.Component.assign(:__shared_assigns_versions__, new_versions)
  end

  @doc """
  Updates a context value using the given function, similar to `Map.update/4`.

  ## Examples

      socket = SharedAssigns.update(socket, :notifications, [], &([new_msg | &1]))
      socket = SharedAssigns.update(socket, :count, 0, &(&1 + 1))
  """
  def update(socket, key, default, fun) when is_function(fun, 1) do
    current_value = get(socket, key, default)
    new_value = fun.(current_value)
    put(socket, key, new_value)
  end

  @doc false
  def initialize_contexts(socket, contexts) do
    initial_contexts = Map.new(contexts)
    initial_versions = Map.new(contexts, fn {key, _value} -> {key, 1} end)

    socket
    |> Phoenix.LiveView.put_private(:__shared_assigns_contexts__, initial_contexts)
    |> Phoenix.Component.assign(:__shared_assigns_versions__, initial_versions)
  end
end
