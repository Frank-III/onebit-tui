# FFI Integration Status

## Current Issues

1. **Type Mismatches**: Float vs Double in FFI bindings
2. **Build Target**: FFI only works with `--target native`, not wasm
3. **Circular Dependencies**: Core depends on FFI, FFI originally depended on Core (fixed)
4. **Syntax Issues**: MoonBit labeled argument syntax changed

## What's Working

1. OpenTUI native library is installed: `node_modules/@opentui/core-darwin-arm64/libopentui.dylib`
2. C wrapper exists: `src/ffi/opentui_wrap.c`
3. FFI bindings are defined in `terminal_ffi.mbt`

## To Fix

1. Fix type issues in FFI (Float → Double)
2. Fix labeled argument syntax (~ placement)
3. Ensure native target builds correctly
4. Test FFI functionality

## Build Commands

```bash
# Build for native (required for FFI)
moon build --target native

# Test FFI package
moon test --target native --package moonbit-community/onebit-tui/ffi

# Run FFI examples
moon run --target native src/examples/ffi_demo.mbt
```

## Architecture Decision

We decided on: **Core depends on FFI**

- FFI provides raw bindings (no dependencies)
- Core uses FFI to implement rendering
- Components use Core
- Apps use Core + Components

This makes FFI the foundation of everything.
