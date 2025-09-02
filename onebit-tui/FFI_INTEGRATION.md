# FFI Integration in OneBit-TUI

## Overview

OneBit-TUI supports two rendering backends:

1. **Pure MoonBit**: Uses ANSI escape codes (portable, no dependencies)
2. **FFI + Zig**: Hardware-accelerated rendering via OpenTUI

## FFI Architecture

```
MoonBit Components
       ↓
  View System
       ↓
TerminalBuffer (MoonBit)
       ↓
  FFI Bridge
       ↓
OpenTUI (Zig/C)
       ↓
Terminal Output
```

## Using FFI

### Basic FFI Rendering

```moonbit
// Create renderer
match @ffi.Renderer::new(80, 24) {
  None => println("FFI not available")
  Some(renderer) => {
    // Get buffer
    let buffer = renderer.get_next_buffer()

    // Draw
    buffer.draw_text("Hello FFI!", 10, 5,
      fg_r=1.0, fg_g=1.0, fg_b=1.0)

    // Render
    renderer.render(force=true)

    // Cleanup
    renderer.destroy()
  }
}
```

### With Component System

```moonbit
// Create UI with clean API
let ui = vstack([
  text("FFI Rendering", style=TextStyle::Bold),
  box(title="Status", children=[
    text("Connected ✓")
  ])
])

// Render to MoonBit buffer first
let mb_buffer = TerminalBuffer::new(80, 24)
ui.render(RenderContext { buffer: mb_buffer, bounds: ... })

// Transfer to FFI
transfer_buffer_to_ffi(mb_buffer, ffi_buffer)
```

## Benefits of FFI

1. **Performance**: Hardware acceleration, optimized rendering
2. **Features**: Double buffering, true color support
3. **Native**: Direct terminal manipulation
4. **Threads**: Separate rendering thread

## When to Use Each Backend

### Use Pure MoonBit When:

- Maximum portability needed
- Running in constrained environments
- Simple UIs with basic colors
- No native dependencies allowed

### Use FFI When:

- Performance is critical
- Need advanced features
- Building complex TUIs
- Hardware acceleration available

## Building with FFI

The FFI requires the OpenTUI native library:

```bash
# Install OpenTUI
npm install @opentui/core-darwin-arm64  # or your platform

# Build with FFI support
moon build --target native
```

## Fallback Strategy

Always provide fallback to pure MoonBit:

```moonbit
match @ffi.Renderer::new(...) {
  None => {
    // Fallback to ANSI
    let buffer = TerminalBuffer::new(80, 24)
    ui.render(...)
    println(buffer.to_ansi())
  }
  Some(renderer) => {
    // Use FFI
    ...
  }
}
```

This ensures your app works everywhere!
