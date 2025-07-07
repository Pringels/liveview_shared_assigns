# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2024-12-19

### Added
- Initial release of SharedAssigns library
- `SharedAssigns.Provider` macro for LiveViews to declare context providers
- `SharedAssigns.Consumer` macro for LiveComponents to subscribe to specific contexts
- Automatic context injection into component assigns
- Version tracking for granular reactivity
- Zero-boilerplate declarative API
- Comprehensive test suite with 18 passing tests
- Complete documentation with usage examples
- MIT license

### Features
- Eliminates prop drilling in Phoenix LiveView applications
- Granular re-renders - only components using changed contexts update
- Clean, React Context-like API for Elixir/Phoenix developers
- Automatic context value injection without manual passing
- Version-based change detection for optimal performance

