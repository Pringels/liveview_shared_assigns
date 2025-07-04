# SharedAssigns

A React Context-like library for Phoenix LiveView that eliminates prop drilling by allowing components to subscribe to specific context values and automatically re-render when those contexts change.

## Features

- 🚀 **Zero boilerplate** - Declarative API with simple macros
- ⚡ **Granular reactivity** - Only components using changed contexts re-render
- 🎯 **Type-safe context access** - Compile-time context key validation
- 📦 **Automatic context injection** - No manual prop drilling required
- 🔄 **Version tracking** - Efficient updates across component trees
- 🧪 **Fully tested** - Comprehensive test suite included

## Installation

Add `shared_assigns` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shared_assigns, "~> 0.1.0"}
  ]
end
```

## Quick Start

### 1. Define a Provider (LiveView)

```elixir
defmodule MyAppWeb.PageLive do
  use MyAppWeb, :live_view
  use SharedAssigns.Provider,
    contexts: [
      theme: "light",
      user_role: "guest",
      notifications: []
    ]

  def handle_event("toggle_theme", _params, socket) do
    new_theme = if get_context(socket, :theme) == "light", do: "dark", else: "light"
    {:noreply, put_context(socket, :theme, new_theme)}
  end

  def handle_event("update_role", %{"role" => role}, socket) do
    {:noreply, put_context(socket, :user_role, role)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.live_component
        module={MyAppWeb.HeaderComponent}
        id="header"
        __parent_contexts__={extract_contexts([:theme, :user_role])}
        __shared_assigns_versions__={@__shared_assigns_versions__}
      />
      
      <button phx-click="toggle_theme">
        Toggle Theme (Current: {get_context(@socket, :theme)})
      </button>
    </div>
    """
  end
end
```

### 2. Create Consumer Components

```elixir
defmodule MyAppWeb.HeaderComponent do
  use MyAppWeb, :live_component
  use SharedAssigns.Consumer, contexts: [:theme]

  def render(assigns) do
    ~H"""
    <header class={["header", @theme == "dark" && "dark-theme"]}>
      <h1>My App</h1>
      <p>Current theme: {@theme}</p>
    </header>
    """
  end
end
```

### 3. Granular Subscriptions

Different components can subscribe to different contexts:

```elixir
defmodule MyAppWeb.SidebarComponent do
  use MyAppWeb, :live_component
  use SharedAssigns.Consumer, contexts: [:user_role]

  def render(assigns) do
    ~H"""
    <nav class="sidebar">
      <%= if @user_role == "admin" do %>
        <.link href="/admin">Admin Panel</.link>
      <% end %>
      <%= if @user_role in ["admin", "user"] do %>
        <.link href="/dashboard">Dashboard</.link>
      <% end %>
    </nav>
    """
  end
end

defmodule MyAppWeb.ThemeToggleComponent do
  use MyAppWeb, :live_component
  use SharedAssigns.Consumer, contexts: [:theme]

  def render(assigns) do
    ~H"""
    <button phx-click="toggle_theme" class={["btn", @theme]}>
      Switch to {if @theme == "light", do: "dark", else: "light"} mode
    </button>
    """
  end
end
```

## API Reference

### Provider Functions

When you `use SharedAssigns.Provider`, your LiveView gets these helper functions:

#### `put_context(socket, key, value)`
Sets a context value and triggers re-renders for consuming components.

```elixir
socket = put_context(socket, :theme, "dark")
```

#### `update_context(socket, key, function)`
Updates a context value using a function.

```elixir
socket = update_context(socket, :count, &(&1 + 1))
```

#### `get_context(socket, key)`
Gets the current value of a context.

```elixir
theme = get_context(socket, :theme)
```

#### `context_keys()`
Returns all available context keys for this provider.

```elixir
keys = MyLive.context_keys()  # [:theme, :user_role, :notifications]
```

### Core Functions

These functions are available from the `SharedAssigns` module:

#### `initialize_contexts(socket, contexts)`
Initializes context storage in a socket (called automatically by Provider macro).

#### `contexts_changed?(socket, keys, last_versions)`
Checks if any of the given context keys have changed (used internally by Consumer).

#### `extract_contexts(socket, keys)`
Extracts context values for given keys into a map.

## How It Works

SharedAssigns uses a version-based reactivity system:

1. **Context Storage**: Contexts are stored in the LiveView socket assigns
2. **Version Tracking**: Each context has a version number that increments on changes
3. **Selective Updates**: Consumer components track last known versions
4. **Granular Re-renders**: Only components with outdated versions re-render

## Best Practices

### 1. Keep Contexts Focused
Create specific contexts rather than one large context:

```elixir
# ✅ Good - Focused contexts
use SharedAssigns.Provider,
  contexts: [
    theme: "light",
    user_role: "guest",
    notifications: []
  ]

# ❌ Avoid - Monolithic context
use SharedAssigns.Provider,
  contexts: [
    app_state: %{theme: "light", user: %{}, notifications: [], ...}
  ]
```

### 2. Subscribe Only to Needed Contexts
Components should only subscribe to contexts they actually use:

```elixir
# ✅ Good - Only subscribes to needed context
use SharedAssigns.Consumer, contexts: [:theme]

# ❌ Avoid - Subscribes to unused contexts
use SharedAssigns.Consumer, contexts: [:theme, :user_role, :notifications]
```

### 3. Use Semantic Context Names
Choose clear, descriptive names for your contexts:

```elixir
# ✅ Good
contexts: [
  theme: "light",
  user_role: "guest",
  sidebar_collapsed: false
]

# ❌ Avoid
contexts: [
  light",
  state: "guest",
  flag: false
]
```

## Performance

SharedAssigns is designed for optimal performance:

- **Minimal overhead**: Version checking is O(1)
- **Selective updates**: Only changed contexts trigger re-renders
- **Memory efficient**: Contexts stored in socket assigns
- **Zero JavaScript**: Pure Elixir implementation

## Testing

SharedAssigns includes comprehensive test helpers:

```elixir
defmodule MyAppWeb.HeaderComponentTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders with theme context" do
    {:ok, view, _html} = live_isolated(build_conn(), MyAppWeb.HeaderComponent,
      __parent_contexts__: %{theme: "dark"},
      __shared_assigns_versions__: %{theme: 1}
    )

    assert has_element?(view, ".header.dark-theme")
  end
end
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for your changes
4. Ensure all tests pass (`mix test`)
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

