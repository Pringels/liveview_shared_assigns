# SharedAssigns Library Plan

A React Context-like library for Phoenix LiveView to eliminate prop drilling.

## Core Design
- **Provider**: Root LiveView declares initial context with `use SharedAssigns.Provider`
- **Consumer**: Components declare needed keys with `use SharedAssigns.Consumer`
- **Reactivity**: Granular re-renders using version tracking in assigns
- **Zero boilerplate**: Declarative API with automatic context injection

## Implementation Steps
- [x] Generate Phoenix project `shared_assigns_demo`
- [x] Create detailed plan and start server
- [x] Create core `SharedAssigns` module with put/update functions
- [x] Implement `SharedAssigns.Provider` macro for context initialization  
- [x] Implement `SharedAssigns.Consumer` macro with automatic context injection
- [x] Replace home page with static mockup showing our demo design
- [x] Create demo PageLive as Provider with theme/user_role contexts
- [x] Create HeaderComponent as Consumer of theme context
- [x] Create SidebarComponent as Consumer of user_role context  
- [x] Create nested UserCardComponent showing granular re-renders
- [x] Update layouts to match our demo design
- [x] Test theme switching and user role changes
- [x] Verify granular re-renders work correctly
- [x] Complete SharedAssigns library implementation

## Demo Features ✅
- Theme switching (light/dark) with automatic component updates
- User role management (guest/user/admin) with role-based navigation
- Nested components showing selective re-renders based on context subscriptions
- Real-time context updates without prop drilling
- Zero boilerplate declarative API

## Library Status: COMPLETE 🎉
The SharedAssigns library successfully eliminates prop drilling in LiveView with:
- Simple `use SharedAssigns.Provider` and `use SharedAssigns.Consumer` macros
- Automatic context injection into component assigns
- Granular reactivity - only components using changed contexts re-render
- Clean, declarative API perfect for open source adoption

