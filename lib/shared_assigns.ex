defmodule SharedAssigns do
  @moduledoc """
  Core functionality for SharedAssigns context management.

  This module provides the foundational functions for initializing, getting,
  and updating contexts that are used by Provider and Consumer modules.
  """

  import Phoenix.Component, only: [assign: 3]

  @doc """
  Initializes contexts in a LiveView socket with default values and version tracking.
  """
  def initialize_contexts(socket, contexts) do
    # Initialize context values
    context_assigns = Enum.into(contexts, %{})

    # Initialize version tracking for each context
    context_versions =
      contexts
      |> Keyword.keys()
      |> Enum.map(fn key -> {key, 1} end)
      |> Enum.into(%{})

    socket
    |> assign(:__shared_assigns_contexts__, context_assigns)
    |> assign(:__shared_assigns_versions__, context_versions)
    |> then(fn sock ->
      Enum.reduce(context_assigns, sock, fn {key, value}, acc ->
        assign(acc, key, value)
      end)
    end)
  end

  @doc """
  Gets the current value of a context.
  """
  def get_context(socket, key) do
    contexts = Map.get(socket.assigns, :__shared_assigns_contexts__, %{})
    Map.get(contexts, key)
  end

  @doc """
  Gets the current version of a context.
  """
  def get_context_version(socket, key) do
    versions = Map.get(socket.assigns, :__shared_assigns_versions__, %{})
    Map.get(versions, key, 0)
  end

  @doc """
  Puts a new value for a context and increments its version.
  """
  def put_context(socket, key, value) do
    current_version = get_context_version(socket, key)
    new_version = current_version + 1

    current_contexts = Map.get(socket.assigns, :__shared_assigns_contexts__, %{})
    current_versions = Map.get(socket.assigns, :__shared_assigns_versions__, %{})

    new_contexts = Map.put(current_contexts, key, value)
    new_versions = Map.put(current_versions, key, new_version)

    socket
    |> assign(:__shared_assigns_contexts__, new_contexts)
    |> assign(:__shared_assigns_versions__, new_versions)
    |> assign(key, value)
  end

  @doc """
  Updates a context value using the given function and increments its version.
  """
  def update_context(socket, key, fun) do
    current_value = get_context(socket, key)
    new_value = fun.(current_value)
    put_context(socket, key, new_value)
  end

  @doc """
  Returns all available context keys for the given socket.
  """
  def context_keys(socket) do
    contexts = Map.get(socket.assigns, :__shared_assigns_contexts__, %{})
    Map.keys(contexts)
  end

  @doc """
  Returns all current context values as a map.
  """
  def all_contexts(socket) do
    Map.get(socket.assigns, :__shared_assigns_contexts__, %{})
  end

  @doc """
  Returns all current context versions as a map.
  """
  def all_context_versions(socket) do
    Map.get(socket.assigns, :__shared_assigns_versions__, %{})
  end

  @doc """
  Extracts specific context values from the socket.
  """
  def extract_contexts(socket, keys) do
    contexts = Map.get(socket.assigns, :__shared_assigns_contexts__, %{})

    keys
    |> Enum.map(fn key -> {key, Map.get(contexts, key)} end)
    |> Enum.into(%{})
  end
end
