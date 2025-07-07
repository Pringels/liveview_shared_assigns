# SharedAssigns API Improvement

## Before: Clunky Manual Context Passing

```elixir
defmodule MyApp.MainLive do
  use Phoenix.LiveView
  use SharedAssigns.Provider, contexts: [theme: "light", user: %{name: "Guest"}]

  # Helper function you had to write for every LiveView
  defp extract_contexts(socket, keys) do
    keys
    |> Enum.map(fn key -> {key, get_context(socket, key)} end)
    |> Enum.into(%{})
  end

  def render(assigns) do
    ~H"""
    <!-- Verbose and error-prone -->
    <.live_component
      module={MyApp.HeaderComponent}
      id="header"
      __parent_contexts__={extract_contexts(@socket, [:theme, :user])}
      __shared_assigns_versions__={@__shared_assigns_versions__}
    />
    
    <.live_component
      module={MyApp.SidebarComponent}
      id="sidebar"
      __parent_contexts__={extract_contexts(@socket, [:user])}
      __shared_assigns_versions__={@__shared_assigns_versions__}
    />
    """
  end
end
```

**Problems:**
- 😞 Verbose and repetitive
- 😞 Error-prone (easy to forget contexts or versions)
- 😞 Manual context extraction for every component
- 😞 Developer has to remember which contexts each component needs
- 😞 Doesn't scale well with many components

## After: Seamless Automatic Context Injection

```elixir
defmodule MyApp.MainLive do
  use Phoenix.LiveView
  use SharedAssigns.Provider, contexts: [theme: "light", user: %{name: "Guest"}]

  def render(assigns) do
    ~H"""
    <!-- Clean and automatic -->
    <.sa_component module={MyApp.HeaderComponent} id="header" />
    <.sa_component module={MyApp.SidebarComponent} id="sidebar" />
    """
  end
end
```

**Benefits:**
- ✅ **Clean and minimal** - Just like regular live_component
- ✅ **Automatic context detection** - Knows what each component needs
- ✅ **Error-free** - No manual context passing to forget
- ✅ **Zero boilerplate** - No helper functions needed
- ✅ **Scales beautifully** - Works the same with 1 or 100 components

## How It Works

The `sa_component` function:

1. **Detects** if the target component uses SharedAssigns
2. **Inspects** what contexts the component subscribes to
3. **Extracts** only the needed contexts from the current socket
4. **Injects** them automatically with proper versioning
5. **Falls back** to regular live_component for non-SharedAssigns components

This provides a **React Context-like experience** that feels natural and eliminates all the manual plumbing!
