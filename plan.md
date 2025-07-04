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
- [ ] Create core `SharedAssigns` module with put/update functions
- [ ] Implement `SharedAssigns.Provider` macro for context initialization  
- [ ] Implement `SharedAssigns.Consumer` macro with on_mount hooks
- [ ] Replace home page with static mockup showing our demo design
- [ ] Create demo PageLive as Provider with theme/user_role contexts
- [ ] Create HeaderComponent as Consumer of theme context
- [ ] Create SidebarComponent as Consumer of user_role context  
- [ ] Create nested UserCardComponent showing granular re-renders
- [ ] Update layouts to match our demo design
- [ ] Add comprehensive tests for the library
- [ ] Document API and create usage examples
- [ ] Structure as extractable library with proper module organization
- [ ] Visit running app to verify everything works

## Demo Features
- Theme switching (light/dark) 
- User role management (guest/user/admin)
- Nested components showing selective re-renders
- Real-time context updates without prop drilling
