# OneBit-TUI FFI Architecture

## Overview

OneBit-TUI uses OpenTUI's FFI exclusively for all rendering. This provides:

- Hardware-accelerated rendering via Zig
- Native terminal control
- High performance
- Well-maintained backend

## Architecture

```
┌─────────────────┐
│   Application   │
└────────┬────────┘
         │
┌────────▼────────┐
│   View System   │ (Declarative API)
│  ┌──────────┐   │
│  │   box    │   │
│  │   text   │   │
│  │  vstack  │   │
│  └──────────┘   │
└────────┬────────┘
         │
┌────────▼────────┐
│  FFI Renderer   │
│ ┌────────────┐  │
│ │ @ffi.Buffer│  │
│ └────────────┘  │
└────────┬────────┘
         │
┌────────▼────────┐
│   OpenTUI FFI   │ (Zig/C)
└─────────────────┘
```

## Key Components

### 1. View System (`/src/core/view.mbt`)

Declarative component API with smart constructors:

```moonbit
let ui = vstack([
  text("Hello", style=TextStyle::Bold),
  box(title="Status", children=[...])
])
```

### 2. FFI Renderer (`/src/renderer/`)

Direct rendering to OpenTUI buffer:

- `FFIRenderer` - Main renderer class
- `view_ffi.mbt` - View rendering implementations

### 3. OpenTUI FFI (`/src/ffi/`)

Low-level bindings to OpenTUI:

- Hardware acceleration
- Double buffering
- Native terminal control

## Usage

```moonbit
// Initialize FFI renderer
match @renderer.setup_terminal() {
  None => println("FFI not available")
  Some(renderer) => {
    // Clear screen
    renderer.clear()

    // Create UI
    let ui = vstack([
      text("Hello OpenTUI!"),
      box(title="Demo", children=[
        text("FFI Rendering")
      ])
    ])

    // Render
    renderer.render_view(ui)
    renderer.present()

    // Cleanup
    @renderer.restore_terminal(renderer)
  }
}
```

## Benefits of FFI-Only Approach

1. **Performance**: Direct hardware rendering
2. **Maintenance**: OpenTUI handles terminal complexities
3. **Features**: Access to all OpenTUI capabilities
4. **Simplicity**: No dual-backend complexity

## Package Structure

```
src/
├── core/          # Core types and view system
├── components/    # Legacy components (being phased out)
├── renderer/      # FFI rendering implementation
├── ffi/          # OpenTUI bindings
└── examples/     # Demo applications
```

## Future Direction

- Remove legacy TerminalBuffer code
- Simplify component system to work directly with FFI
- Add event handling through OpenTUI
- Implement animations using OpenTUI's frame timing

This architecture leverages OpenTUI's well-maintained FFI for all terminal operations, ensuring reliability and performance.
