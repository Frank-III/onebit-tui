# Improved FFI-First Architecture

## Goal

Build everything on top of OpenTUI FFI as the foundation, making it the core of our system.

## Proposed Structure

```
ffi/              # OpenTUI bindings (lowest level)
 ↑
core/             # Core types + FFI integration
 ↑
components/       # High-level components
 ↑
app/              # Application code
```

## Option 1: Core Depends on FFI (Recommended)

```
src/
├── ffi/          # Pure OpenTUI bindings
│   ├── terminal_ffi.mbt
│   └── moon.pkg.json
│
├── core/         # Core system built on FFI
│   ├── types.mbt        # Basic types (RGBA, Rect, etc)
│   ├── renderer.mbt     # FFI-based renderer
│   ├── view.mbt         # View system using FFI
│   └── moon.pkg.json    # imports: ["../ffi"]
│
├── components/   # High-level components
│   ├── box.mbt
│   ├── text.mbt
│   └── moon.pkg.json    # imports: ["../core"]
│
└── app/          # Example apps
    └── moon.pkg.json    # imports: ["../core", "../components"]
```

### Benefits:

- Clear dependency hierarchy
- Core has direct access to FFI
- No intermediate layers
- Simple mental model

## Option 2: Merged FFI+Core

Merge FFI and core into a single package since they're tightly coupled:

```
src/
├── core/         # Core + FFI combined
│   ├── ffi/
│   │   └── terminal_ffi.mbt
│   ├── types.mbt
│   ├── renderer.mbt
│   ├── view.mbt
│   └── moon.pkg.json
│
└── components/   # High-level components
    └── moon.pkg.json    # imports: ["../core"]
```

### Benefits:

- Even simpler structure
- FFI is truly part of core
- Less packages to manage

## Option 3: FFI as Foundation Layer

Make FFI the true foundation with everything else as extensions:

```
src/
├── opentui/      # Rename ffi to opentui (the foundation)
│   ├── bindings.mbt     # Raw FFI bindings
│   ├── renderer.mbt     # Renderer abstraction
│   ├── buffer.mbt       # Buffer operations
│   └── moon.pkg.json
│
├── ui/           # UI framework built on OpenTUI
│   ├── view.mbt
│   ├── components.mbt
│   └── moon.pkg.json    # imports: ["../opentui"]
│
└── examples/
```

### Benefits:

- Makes it clear OpenTUI is the foundation
- Clean separation of concerns
- Easy to understand dependency flow

## Recommendation: Option 1

Make core depend on FFI directly. This is the most straightforward approach that:

1. Keeps FFI bindings separate and clean
2. Allows core to build directly on FFI
3. Maintains clear package boundaries
4. Makes the dependency flow obvious

## Implementation Plan

1. Update core/moon.pkg.json to import FFI
2. Move renderer functionality into core
3. Update view system to render directly via FFI
4. Remove intermediate renderer package
5. Simplify component system to use core's FFI integration

This gives us a clean, FFI-first architecture where OpenTUI is the foundation of everything.
