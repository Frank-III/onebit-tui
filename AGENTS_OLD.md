# Agent Guidelines for opentui

## Project Focus

**OneBit-TUI (MoonBit) is the PRIMARY project** - located in `/onebit-tui/`
- TypeScript packages are only for upstream API reference
- Always sync with upstream OpenTUI to keep our API compatible
- Build with `moon build --target native` (NOT wasm-gc) for FFI support
- Core, components, and FFI packages build successfully - focus on fixing demos

## TypeScript/Bun Development (For Reference Only)

Default to using Bun instead of Node.js.

- Use `bun <file>` instead of `node <file>` or `ts-node <file>`
- Use `bun test` instead of `jest` or `vitest`
- Use `bun build` instead of `webpack` or `esbuild`
- Use `bun install` instead of `npm install`
- Bun automatically loads .env, don't use dotenv

NOTE: When only changing TypeScript, you do NOT need to run the build script.
The build is only needed when changing native code.

## APIs

- `Bun.serve()` supports WebSockets, HTTPS, and routes. Don't use `express`.
- `bun:sqlite` for SQLite. Don't use `better-sqlite3`.
- Prefer `Bun.file` over `node:fs`
- `Bun.$` for shell commands instead of execa

## Testing

```ts
import { test, expect } from "bun:test";
test("hello world", () => {
  expect(1).toBe(1);
});
```

## MoonBit Development

### CRITICAL: Build Target
**ALWAYS use `moon build --target native`** - The `wasm-gc` target doesn't support `extern "C"` FFI functions!

### Core Library First Rule

**ALWAYS check https://github.com/moonbitlang/core before implementing ANY data structure or algorithm.**

Core provides: `hashmap`, `hashset`, `queue`, `deque`, `priority_queue`, `sorted_map`, `sorted_set`, `list`, `immut`, `iter`, `json`, `random`, `math`, and more.

### Built-in Types (No Import Needed)

```moonbit
// ✅ These work without imports
let counter : Ref[Int] = Ref::new(0)  
let optional : String? = Some("hello")
let items : Array[String] = []
let fixed : FixedArray[Int] = FixedArray::make(10, 0)
```

### Non-Built-in Types (Workarounds Needed)

For types like HashMap that exist in core but aren't built-in:
1. **Import syntax doesn't work** in moon.pkg.json
2. **Create simple implementation** as workaround
3. **Document for future** when imports are fixed

Example workaround:
```moonbit
// HashMap import doesn't work, so we create KeyMap
pub struct KeyMap {
  mut entries : Array[(String, () -> Unit)]
}

pub fn KeyMap::new() -> KeyMap {
  { entries: [] }
}

pub fn KeyMap::get(self : KeyMap, key : String) -> (() -> Unit)? {
  for entry in self.entries {
    if entry.0 == key { return Some(entry.1) }
  }
  None
}
```

### Common Compilation Fixes

1. **Float to Int conversion**: Use explicit chain
   ```moonbit
   // ❌ Wrong: value.to_int()
   // ✅ Right: value.to_double().to_int()
   ```

2. **Struct literals**: Must match exact fields
   ```moonbit
   // ❌ Wrong: { x, y, width: 100 }  // missing height
   // ✅ Right: { x, y, width: 100, height: 50 }
   ```

3. **Method syntax**: Use :: for type methods
   ```moonbit
   // ❌ Wrong: Array.make(10, 0)
   // ✅ Right: Array::make(10, 0)
   ```

4. **Suppress warnings**: Add to moon.pkg.json
   ```json
   {
     "warn-list": "-15"  // Suppress unused mutability warnings
   }
   ```

### AppV2 Design Pattern

Use closures for callbacks to avoid reference/value issues:

```moonbit
pub struct AppV2 {
  mut on_key : () -> Unit      // No App parameter!
  mut on_resize : () -> Unit   // Closure captures what it needs
  mut on_update : () -> Unit
}

// Usage
let app = AppV2::new()
app.on_key = fn() {
  // Access app state via closure, not parameter
}
```

### Best Practices

1. **Check core library FIRST** - https://github.com/moonbitlang/core
2. **Use built-in types** - Ref, Option, Array work directly
3. **Test types directly** - Don't assume imports are needed
4. **Create simple implementations** only when core import fails
5. **Comment out broken code** - Don't force implementations with wrong types
6. **Focus on getting FFI working** - Start with minimal demos that use FFI directly

### Current State Summary

- **Working**: Core, components, FFI packages compile
- **24 "errors"**: Actually just unused mutability warnings
- **1200+ real errors**: In demo files trying to use incomplete features
- **Next step**: Fix a real demo that actually uses the FFI layer

## Package Management

### Use pnpm for Node.js projects
- Use `pnpm add <package>` instead of `npm install`
- Use `pnpm add -D <package>` for dev dependencies
- Never modify package.json directly
- Check if pnpm is available first, fall back to npm if needed