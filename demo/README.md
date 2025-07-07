# SharedAssigns Demo

A simple, clean demonstration of the SharedAssigns library for Phoenix LiveView.

## What This Demo Shows

### 🏗️ Context Provider (Root LiveView)
- **File**: `lib/demo_web/live/main_demo_live.ex`
- Sets up three simple contexts:
  - `theme`: "light" or "dark"
  - `user`: `%{name: string, role: string}`
  - `counter`: integer

### 📦 Context Consumers (Components)
- **HeaderComponent**: Consumes `theme` + `user` contexts
- **UserInfoComponent**: Consumes `user` + `theme` contexts  
- **CounterDisplayComponent**: Consumes `counter` + `theme` contexts

### 🔄 Nested LiveView
- **ChildDemoLive**: Demonstrates how child LiveViews can receive contexts from parents
- Shows read-only context consumption
- Maintains its own local state alongside parent contexts

## Key Features Demonstrated

✅ **Context Provider Setup** - Simple context initialization in root LiveView  
✅ **Granular Subscriptions** - Components only subscribe to contexts they need  
✅ **Automatic Re-rendering** - Only components using changed contexts update  
✅ **Nested LiveViews** - Child LiveViews can consume parent contexts  
✅ **Theme Switching** - Real-time UI updates across all components  
✅ **Role-based Content** - Conditional rendering based on user context  

## How to Use

1. **Toggle Theme**: Watch all components update their styling instantly
2. **Change User**: See role-based content appear/disappear across components
3. **Increment/Decrement Counter**: Observe only the counter component re-renders
4. **Update Child Message**: Local state in child LiveView works alongside parent contexts

## Architecture

```
MainDemoLive (Provider)
├── HeaderComponent (Consumer: theme, user)
├── UserInfoComponent (Consumer: user, theme)
├── CounterDisplayComponent (Consumer: counter, theme)
└── ChildDemoLive (Receives: theme, user, counter)
```

This demonstrates the core SharedAssigns pattern: **declarative context management with granular reactivity**.
