# SharedAssigns Demo - Live Browser Demo

A complete, runnable Phoenix LiveView application demonstrating SharedAssigns functionality.

## 🚀 Quick Start

### Option 1: Automated Start Script
```bash
# From the project root
./start_demo.sh
```

### Option 2: Manual Setup
```bash
# Navigate to demo directory
cd demo

# Install dependencies
mix deps.get

# Start the Phoenix server
mix phx.server
```

Then visit **http://localhost:4000** in your browser!

## 🎯 What You'll See

### ✨ Seamless Context Management
- **Clean Component Usage**: Notice how components use `<.sa_component module={...} socket={@socket} />` instead of manual context passing
- **Automatic Context Injection**: SharedAssigns automatically detects what contexts each component needs
- **No Boilerplate**: No more `extract_contexts()` helper functions or manual `__parent_contexts__` passing

### 🔄 Real-Time Updates
- **Theme Toggle**: Watch all components instantly update their styling when you switch themes
- **User Role Changes**: See role-based content appear/disappear across all components  
- **Counter Updates**: Observe that only the counter component re-renders when counter changes
- **Nested LiveView**: Child LiveView automatically receives and reacts to parent context changes

### 📦 Component Architecture
```
MainDemoLive (Provider)
├── HeaderComponent (Consumes: theme, user)
├── UserInfoComponent (Consumes: user, theme)  
├── CounterDisplayComponent (Consumes: counter, theme)
└── ChildDemoLive (Receives: theme, user, counter)
```

## 🔍 Key Demo Features

✅ **Context Provider Setup** - Root LiveView managing 3 simple contexts  
✅ **Granular Subscriptions** - Each component only gets contexts it needs  
✅ **Seamless Integration** - Clean, React-like component usage  
✅ **Automatic Re-rendering** - Only affected components update  
✅ **Nested LiveViews** - Child LiveViews receive parent contexts  
✅ **Beautiful UI** - Tailwind CSS styling with dark/light theme switching  

## 🎨 Interactive Elements

1. **Theme Toggle** - Switch between light/dark modes
2. **User Management** - Change name and role (guest/user/admin)  
3. **Counter Controls** - Increment/decrement with visual feedback
4. **Role-Based Content** - Admin/user panels that appear based on role
5. **Child LiveView** - Shows context consumption in nested LiveViews

This demonstrates the power of **SharedAssigns**: React Context-like functionality for Phoenix LiveView with zero boilerplate!
