# SharedAssigns: Potential Improvements

This document outlines potential enhancements and improvements to the SharedAssigns library. These are ideas for future development that could enhance performance, developer experience, and functionality.

## Performance Optimizations

### 1. Batched Updates
Currently, each `put_context` call immediately triggers `send_update/3` for all subscribers. This could cause unnecessary updates if multiple contexts change in quick succession.

**Current Behavior:**
```elixir
# 3 separate send_update calls
put_context(socket, :theme, "dark")
put_context(socket, :user_role, "admin") 
put_context(socket, :notifications, [])
```

**Potential Improvement:**
```elixir
# Single batched update
batch_update_contexts(socket, %{
  theme: "dark",
  user_role: "admin", 
  notifications: []
})

# Or automatic batching within a single function
def handle_event("setup_user", _params, socket) do
  socket = 
    socket
    |> put_context(:theme, "dark")
    |> put_context(:user_role, "admin")
    |> put_context(:notifications, [])
    |> flush_context_updates()  # Batch all changes
  
  {:noreply, socket}
end
```

### 2. Smart Diffing
The library could avoid sending updates when values haven't actually changed.

**Current Behavior:**
```elixir
put_context(socket, :theme, "dark")  # Always triggers updates, even if theme was already "dark"
```

**Potential Improvement:**
```elixir
# Skip updates when value hasn't changed
put_context(socket, :theme, "dark")  # No-op if already "dark"

# Optional force update
put_context(socket, :theme, "dark", force: true)  # Always update
```

### 3. Subscription Granularity
Components could subscribe to specific paths within complex contexts.

**Current Behavior:**
```elixir
# Must subscribe to entire user object
def subscribed_contexts, do: [:user]
# Component gets all user changes, even if it only cares about the name
```

**Potential Improvement:**
```elixir
# Subscribe to specific fields
def subscribed_contexts, do: [user: [:name, :role]]

# Or with transformations
def subscribed_contexts do
  [
    user_name: {:user, :name},
    user_role: {:user, :role}
  ]
end
```

## Developer Experience Improvements

### 4. Compile-Time Validation
The library could validate context usage at compile time.

**Potential Implementation:**
```elixir
# Catch typos/missing contexts at compile time
<.sa_live_component module={MyComponent} id="header" />
# Compile Warning: MyComponent subscribes to :theme but Provider doesn't define it
```

**Benefits:**
- Catch bugs early in development
- Prevent runtime errors
- Better IDE support with warnings

### 5. Better Error Messages
More helpful runtime errors with context about what went wrong.

**Current Error (hypothetical):**
```
** (ArgumentError) invalid context
```

**Improved Error Messages:**
```
** (SharedAssigns.MissingContextError) 
Component HeaderComponent subscribes to [:theme, :user] but Provider only defines [:theme]. 
Missing contexts: [:user]

Hint: Add `user: default_value` to your Provider's contexts list.
```

### 6. DevTools Integration
A LiveView dashboard showing real-time context information.

**Features:**
- Active contexts and their current values
- Which components subscribe to what contexts
- Update frequency and performance metrics
- Context change history
- Visual component tree with context flow

**Usage:**
```elixir
# In development environment
plug SharedAssigns.DevTools

# Access at /shared_assigns_devtools
```

## API Enhancements

### 7. Context Transformations
Allow transforming context values before injection into components.

**Implementation:**
```elixir
defmodule MyComponent do
  use Phoenix.LiveComponent

  def subscribed_contexts do
    [
      theme: &String.upcase/1,        # Transform theme to uppercase
      user_name: {:user, &Map.get(&1, :name)},  # Extract just the name
      user_initial: {:user, &String.first(Map.get(&1, :name, "")))}
    ]
  end
end
```

### 8. Conditional Subscriptions
Dynamic subscriptions based on component state or props.

**Implementation:**
```elixir
def subscribed_contexts(assigns) do
  base = [:theme]
  
  cond do
    assigns[:show_user_info] -> base ++ [:user]
    assigns[:admin_mode] -> base ++ [:user, :permissions]
    true -> base
  end
end

# Or with guards
def subscribed_contexts(_assigns = %{user_role: "admin"}) do
  [:theme, :user, :admin_settings]
end

def subscribed_contexts(_assigns) do
  [:theme, :user]
end
```

### 9. Context Namespacing
Avoid conflicts in complex applications with multiple context providers.

**Implementation:**
```elixir
# Provider with namespace
use SharedAssigns.Provider,
  namespace: :header,
  contexts: [theme: "light", collapsed: false]

# Consumer accesses namespaced contexts
def subscribed_contexts, do: ["header.theme", "header.collapsed"]

# Or with namespace syntax
def subscribed_contexts, do: [header: [:theme, :collapsed]]
```

## Advanced Features

### 10. Context Middleware
Plugin system for cross-cutting concerns.

**Implementation:**
```elixir
defmodule SharedAssigns.Middleware.Logger do
  def before_update(context_key, old_value, new_value, socket) do
    Logger.info("Context #{context_key}: #{inspect(old_value)} -> #{inspect(new_value)}")
    {:ok, new_value}
  end
end

defmodule SharedAssigns.Middleware.Validation do
  def before_update(:theme, _old, new_value, _socket) do
    if new_value in ["light", "dark"] do
      {:ok, new_value}
    else
      {:error, "Invalid theme: #{new_value}"}
    end
  end
end

# Usage
use SharedAssigns.Provider,
  contexts: [theme: "light", user: nil],
  middleware: [
    SharedAssigns.Middleware.Logger,
    SharedAssigns.Middleware.Validation,
    SharedAssigns.Middleware.Persistence  # Auto-save to database
  ]
```

### 11. Time Travel / Undo System
Built-in state history for debugging and undo functionality.

**Implementation:**
```elixir
# Enable history tracking
use SharedAssigns.Provider,
  contexts: [theme: "light"],
  history: true  # or history: 10 for max 10 items

# API for time travel
socket = put_context(socket, :theme, "dark")
socket = put_context(socket, :theme, "blue") 
socket = undo_context(socket, :theme)        # Back to "dark"
socket = undo_context(socket, :theme)        # Back to "light"
socket = redo_context(socket, :theme)        # Forward to "dark"

# Get history
history = get_context_history(socket, :theme)
# [
#   %{value: "light", timestamp: ~U[2025-01-01 10:00:00Z]},
#   %{value: "dark", timestamp: ~U[2025-01-01 10:05:00Z]},
#   %{value: "blue", timestamp: ~U[2025-01-01 10:10:00Z]}
# ]
```

### 12. Computed Contexts
Derived values that automatically update when dependencies change.

**Implementation:**
```elixir
use SharedAssigns.Provider,
  contexts: [
    first_name: "John",
    last_name: "Doe",
    age: 30
  ],
  computed: [
    full_name: [:first_name, :last_name],
    display_name: [:full_name, :age],
    initials: [:first_name, :last_name]
  ]

# Define computation functions
def compute_full_name(first_name, last_name) do
  "#{first_name} #{last_name}"
end

def compute_display_name(full_name, age) do
  "#{full_name} (#{age})"
end

def compute_initials(first_name, last_name) do
  "#{String.first(first_name)}#{String.first(last_name)}"
end
```

## Alternative Architecture Patterns

### 13. Event-Driven Updates
Instead of direct `send_update/3`, use an event system.

**Implementation:**
```elixir
# Provider emits events instead of direct updates
def handle_event("toggle_theme", _params, socket) do
  new_theme = toggle_theme(get_context(socket, :theme))
  socket = emit_context_event(socket, :theme_changed, new_theme)
  {:noreply, socket}
end

# Components handle events
def handle_info({:context_event, :theme_changed, new_theme}, socket) do
  {:noreply, assign(socket, :theme, new_theme)}
end

# Middleware can intercept events
defmodule ThemeMiddleware do
  def handle_event(:theme_changed, new_theme, socket) do
    # Save theme preference to user profile
    save_user_preference(socket.assigns.current_user, :theme, new_theme)
    {:continue, new_theme}
  end
end
```

### 14. Immutable State Trees
Redux-like architecture with pure reducers.

**Implementation:**
```elixir
use SharedAssigns.Provider,
  contexts: [theme: "light", user: nil],
  reducer: MyAppReducer

defmodule MyAppReducer do
  def reduce(state, {:toggle_theme}) do
    new_theme = if state.theme == "light", do: "dark", else: "light"
    %{state | theme: new_theme}
  end
  
  def reduce(state, {:set_user, user}) do
    %{state | user: user}
  end
end

# Usage in LiveView
def handle_event("toggle_theme", _params, socket) do
  {:noreply, dispatch(socket, {:toggle_theme})}
end
```

### 15. Reactive Streams
Stream-based context updates for complex data flows.

**Implementation:**
```elixir
# Subscribe to streams of changes
def mount(_params, _session, socket) do
  theme_stream = SharedAssigns.stream(:theme)
  user_stream = SharedAssigns.stream(:user)
  
  combined_stream = 
    Stream.combine([theme_stream, user_stream])
    |> Stream.map(&transform_data/1)
  
  {:ok, subscribe(socket, combined_stream)}
end

# Reactive operators
def mount(_params, _session, socket) do
  theme_stream = 
    SharedAssigns.stream(:theme)
    |> Stream.debounce(100)  # Wait 100ms between changes
    |> Stream.distinct()     # Only emit on actual changes
    |> Stream.take(10)       # Max 10 updates
  
  {:ok, subscribe(socket, theme_stream)}
end
```

## Testing & Debugging Enhancements

### 16. Mock Contexts
Built-in mocking system for testing.

**Implementation:**
```elixir
defmodule MyAppWeb.HeaderComponentTest do
  use MyAppWeb.ConnCase
  import Phoenix.LiveViewTest
  import SharedAssigns.TestHelpers

  test "renders with mocked theme" do
    with_mock_contexts(theme: "dark", user: %{name: "Test"}) do
      {:ok, view, _html} = live_isolated(build_conn(), HeaderComponent)
      assert has_element?(view, ".dark-theme")
      assert has_element?(view, "[data-user='Test']")
    end
  end

  test "context changes during test" do
    {:ok, view, _html} = live_isolated(build_conn(), HeaderComponent)
    
    # Simulate context change
    mock_context_change(view, :theme, "dark")
    
    assert has_element?(view, ".dark-theme")
  end
end
```

### 17. Context Inspector
Visual debugging tool showing context flow in real-time.

**Features:**
- Real-time context value display
- Component subscription visualization
- Update frequency metrics
- Context change timeline
- Performance bottleneck detection

**Usage:**
```elixir
# In development.exs
config :shared_assigns, :inspector, enabled: true

# Appears as overlay in browser during development
# Shows context tree, active subscriptions, and update flow
```

## Priority Recommendations

If implementing these improvements, I'd recommend this priority order:

### High Priority (Immediate Value)
1. **Smart Diffing** - Prevents unnecessary re-renders with minimal API changes
2. **Better Error Messages** - Significantly improves debugging experience
3. **Compile-Time Validation** - Catches bugs early with no runtime cost

### Medium Priority (Good ROI)
4. **Batched Updates** - Major performance improvement for complex UIs
5. **DevTools Integration** - Excellent for debugging and development
6. **Context Transformations** - Adds flexibility without complexity

### Lower Priority (Nice to Have)
7. **Computed Contexts** - Useful but adds complexity
8. **Time Travel/Undo** - Great for debugging but niche use case
9. **Alternative Architectures** - Significant changes, may not fit all use cases

## Implementation Considerations

### Backward Compatibility
- Most improvements should be additive
- Provide migration guides for breaking changes
- Consider feature flags for experimental features

### Performance Impact
- Benchmark all performance-related changes
- Ensure improvements don't slow down simple use cases
- Profile memory usage for features like history tracking

### Bundle Size
- Keep core library minimal
- Make advanced features optional/pluggable
- Consider separate packages for complex features

### Documentation
- Update examples for new features
- Provide migration guides
- Include performance characteristics in docs

---

*This document represents potential future directions and is not a commitment to implement any specific features. Feedback and contributions are welcome!*
