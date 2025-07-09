# !!! WIP - DO NOT USE IN PRODUCTION !!! #


![Gemini_Generated_Image_1pq9o41pq9o41pq9](https://github.com/user-attachments/assets/b843a628-e3a9-4b70-949f-6ecd8e2e257b)



# SharedAssigns

A React Context-like library for Phoenix LiveView that eliminates prop drilling by allowing components to subscribe to specific context values and automatically re-render when those contexts change.

## Features

- 🚀 **Zero boilerplate** - Declarative API with simple macros
- ⚡ **Explicit assigns-based** - Pure explicit assigns, no process dictionary
- 🔄 **Reactive components** - Automatic `send_update/3` when contexts change
- 🎯 **Granular subscriptions** - Components subscribe only to needed contexts
- 📦 **Automatic context injection** - No manual prop drilling required
- ✨ **Seamless integration** - Works naturally with Phoenix LiveView
- 🧪 **Fully tested** - Comprehensive test suite included

## Quick Start Demo

```bash
./start_demo.sh
# Opens http://localhost:4000 - Live browser demo!
```

## Installation

Add `shared_assigns` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:shared_assigns, "~> 0.1.0"}
  ]
end
```

## Basic Usage

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

  def render(assigns) do
    ~H"""
    <div>
      <!-- Automatic context injection as explicit assigns -->
      <.sa_live_component module={MyAppWeb.HeaderComponent} id="header" />
      
      <button phx-click="toggle_theme">
        Toggle Theme (Current: <%= @theme %>)
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

  # Declare which contexts this component subscribes to
  def subscribed_contexts, do: [:theme]

  def render(assigns) do
    ~H"""
    <header class={["header", @theme == "dark" && "dark-theme"]}>
      <h1>My App</h1>
      <p>Current theme: <%= @theme %></p>
    </header>
    """
  end

  def update(assigns, socket) do
    # Receives context updates via send_update/3
    {:ok, assign(socket, assigns)}
  end
end
```

### 3. Alternative Helper Function Usage

For programmatic usage, you can use the `sa_component/2` helper:

```elixir
def render(assigns) do
  ~H"""
  <.live_component {sa_component(assigns, module: MyComponent, id: "my-id")} />
  """
end
```

## Architecture: Explicit Assigns + send_update/3

SharedAssigns uses a pure explicit assigns approach with reactive updates:

1. **Context Storage**: Contexts stored in `socket.assigns[:__shared_assigns_contexts__]`
2. **Version Tracking**: Each context has a version number in `socket.assigns[:__shared_assigns_versions__]`
3. **Context Updates**: When contexts change, Provider calls `send_update/3` to notify subscribing components
4. **Explicit Assignment**: Context values injected as explicit assigns (e.g., `@theme`, `@user_role`)
5. **Component Reactivity**: Components automatically update via their `update/2` callback

```
Provider (LiveView)
├── Context Storage: socket.assigns[:__shared_assigns_contexts__]
├── Version Tracking: socket.assigns[:__shared_assigns_versions__]
├── Context Updates: Trigger send_update/3 to subscribing components
└── Components receive contexts as explicit assigns
```

**No process dictionary usage anywhere!**

## API Reference

### Provider Functions

When you `use SharedAssigns.Provider`, your LiveView gets these helper functions:

#### `put_context(socket, key, value)`
Sets a context value and automatically triggers `send_update/3` for all consuming components.

```elixir
socket = put_context(socket, :theme, "dark")
# This automatically calls send_update/3 for all components that subscribe to :theme
```

#### `update_context(socket, key, function)`
Updates a context value using a function and triggers component updates.

```elixir
socket = update_context(socket, :count, &(&1 + 1))
# This increments the count and notifies consuming components via send_update/3
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

### Helper Functions

#### `sa_live_component(opts)`
The main macro for creating context-aware LiveComponents. Automatically injects context values as explicit assigns.

```heex
<.sa_live_component module={MyComponent} id="my-id" />
<.sa_live_component module={MyComponent} id="my-id" class="custom-class" />
```

#### `sa_component(parent_assigns, opts)`
Helper function for programmatic context injection.

```elixir
component_assigns = sa_component(assigns, module: MyComponent, id: "my-id")
```

#### `sa_live_session(id, module, assigns, custom_session \\ %{})`
Prepares LiveView session data with context values for nested LiveViews.

```heex
<%= live_render(@socket, MyChildLive, sa_live_session("child", MyChildLive, assigns)) %>
```

## Component Subscription Pattern

Components declare their context dependencies using the `subscribed_contexts/0` function:

```elixir
defmodule MyComponent do
  use Phoenix.LiveComponent

  # Declare which contexts this component subscribes to
  def subscribed_contexts, do: [:theme, :user_role]

  def render(assigns) do
    ~H"""
    <div class={@theme}>User: <%= @user_role %></div>
    """
  end

  def update(assigns, socket) do
    # Contexts are received as explicit assigns
    {:ok, assign(socket, assigns)}
  end
end
```

## PubSub for Nested LiveViews

For cross-LiveView context synchronization, add PubSub:

```elixir
defmodule MyAppWeb.ParentLive do
  use SharedAssigns.Provider,
    contexts: [theme: "light", user: %{}],
    pubsub: MyApp.PubSub  # Enables cross-LiveView sync
end
```

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
def subscribed_contexts, do: [:theme]

# ❌ Avoid - Subscribes to unused contexts
def subscribed_contexts, do: [:theme, :user_role, :notifications]
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
  mode: "light",
  state: "guest",
  flag: false
]
```

## Testing

SharedAssigns components can be easily tested by providing context values directly as assigns:

```elixir
defmodule MyAppWeb.HeaderComponentTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest

  test "renders with theme context" do
    {:ok, view, _html} = live_isolated(build_conn(), MyAppWeb.HeaderComponent,
      theme: "dark",
      __sa_version_theme: 1
    )

    assert has_element?(view, ".header.dark-theme")
  end

  test "renders with different theme" do
    {:ok, view, _html} = live_isolated(build_conn(), MyAppWeb.HeaderComponent,
      theme: "light",
      __sa_version_theme: 1
    )

    refute has_element?(view, ".header.dark-theme")
  end
end
```

## Performance

SharedAssigns is designed for optimal performance:

- **Minimal overhead**: Version checking is O(1) per context
- **Selective updates**: Only components subscribed to changed contexts receive `send_update/3`
- **Explicit assigns**: Context values stored as regular socket assigns for fast access
- **Efficient targeting**: Provider knows exactly which components to update
- **Zero JavaScript**: Pure Elixir implementation

## Demo Application

The repository includes a complete demo application showcasing all features:

```bash
cd demo
mix deps.get
mix phx.server
# Visit http://localhost:4000
```

Features demonstrated:
- Theme switching with instant UI updates
- User role management with conditional content
- Counter state with reactive updates
- Beautiful Tailwind styling
- Nested LiveView synchronization via PubSub

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

