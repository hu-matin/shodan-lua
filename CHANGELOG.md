# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.1] - 2026-09-13

### Added
- Complete Shodan API client for Lua
- 16 API modules covering all Shodan REST endpoints
- Cross-platform HTTP handlers (curl, luasocket, lua_http)
- Structured error handling with 8 error types
- Automatic retries with exponential backoff
- Pure Lua JSON parsing via dkjson
- Time utilities via luatime
- Comprehensive test suite (75+ tests)

### Features
- Search API with pagination, facets, and token parsing
- Host lookup with detailed IP information
- Exploits database search
- DNS resolution (Membership required)
- Network scanning (Membership required)
- Alerts & monitoring (Membership required)
- Streaming support (Enterprise required)
- Bulk data access (Enterprise required)
- Organization management (Enterprise required)
- Saved queries browsing
- Directory access (ports, protocols, services)
- Notifiers configuration
- Account info and profile

### Technical
- Lua 5.1+ compatible (5.1, 5.2, 5.3, 5.4, 5.5, LuaJIT)
- Modular architecture with lazy loading
- Pluggable HTTP backends
- MIT License

### Dependencies
- lua >= 5.1
- dkjson >= 2.1
- luatime
- curl (system requirement, pre-installed on Windows/macOS)

---

## [Unreleased]

### Planned
- Additional examples for Membership and Enterprise features
- Streaming API wrapper improvements
- WebSocket support for real-time data
- Performance optimizations
- More comprehensive error handling