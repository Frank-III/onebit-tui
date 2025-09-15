# OneBit-TUI Development Guide

## Project Focus
**OneBit-TUI** is a MoonBit port of OpenTUI located in `/onebit-tui/`. This is the PRIMARY project.
- TypeScript packages in `/packages/` are for upstream reference only
- Always sync with upstream OpenTUI to maintain API compatibility

## Build Commands
```bash
# ALWAYS use native target for FFI support
moon build --target native

# wasm-gc target does NOT support extern "C" FFI
# Never use: moon build --target wasm-gc
```

## MoonBit Language Essentials

### Built-in Types (No Import Needed)
```moonbit
let counter : Ref[Int] = Ref::new(0)       // Mutable reference
let optional : String? = Some("hello")     // Option type
let items : Array[String] = []             // Dynamic array
let fixed : FixedArray[Int] = FixedArray::make(10, 0)
```

### Common Fixes
```moonbit
// Float to Int conversion - use chain
value.to_double().to_int()  // ✅ Correct
value.to_int()              // ❌ Won't compile

// Method syntax - use :: for type methods  
Array::make(10, 0)          // ✅ Correct
Array.make(10, 0)           // ❌ Wrong

// Struct literals - must match ALL fields
{ x: 0, y: 0, width: 100, height: 50 }  // ✅ All fields
{ x: 0, y: 0, width: 100 }              // ❌ Missing height
```

### Package Structure
- `/src/ffi/` - FFI bindings to C/Zig renderer (WORKING)
- `/src/core/` - Core types and app framework (WORKING)
- `/src/components/` - UI components (WORKING)
- `/src/demo/` - Demo applications (NEEDS WORK)

### Current State
- ✅ FFI layer works - can render to terminal
- ✅ Core, components, FFI packages compile
- ✅ Successfully linked with OpenTUI C library
- ⚠️ 24 unused mutability warnings (suppress with `"warn-list": "-15"`)
- ❌ Most demos have incomplete implementations

## Next Steps
1. Build a real demo showcasing components + layout
2. Fix component implementations (missing Yoga methods)
3. Keep syncing with upstream OpenTUI

## Tips
- Check https://github.com/moonbitlang/core before implementing data structures
- When HashMap import fails, create simple workaround implementation
- Comment out broken code rather than forcing wrong types
- Focus on getting real functionality working, not trivial examples