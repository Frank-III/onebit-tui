# Agent Guidelines for opentui

## TypeScript/Bun Development

Default to using Bun instead of Node.js.

- Use `bun <file>` instead of `node <file>` or `ts-node <file>`
- Use `bun test` instead of `jest` or `vitest`
- Use `bun build <file.html|file.ts|file.css>` instead of `webpack` or `esbuild`
- Use `bun install` instead of `npm install` or `yarn install` or `pnpm install`
- Use `bun run <script>` instead of `npm run <script>` or `yarn run <script>` or `pnpm run <script>`
- Bun automatically loads .env, so don't use dotenv.

NOTE: When only changing typescript, you do NOT need to run the build script.
The build is only needed when changing native code.

## APIs

- `Bun.serve()` supports WebSockets, HTTPS, and routes. Don't use `express`.
- `bun:sqlite` for SQLite. Don't use `better-sqlite3`.
- `Bun.redis` for Redis. Don't use `ioredis`.
- `Bun.sql` for Postgres. Don't use `pg` or `postgres.js`.
- `WebSocket` is built-in. Don't use `ws`.
- Prefer `Bun.file` over `node:fs`'s readFile/writeFile
- Bun.$`ls` instead of execa.

## Testing

Use `bun test` to run tests.

```ts#index.test.ts
import { test, expect } from "bun:test";

test("hello world", () => {
  expect(1).toBe(1);
});
```

For more information, read the Bun API docs in `node_modules/bun-types/docs/**.md`.

## Build/Test Commands

- `bun test` - Run all tests
- `bun test <file>` - Run specific test file (e.g., `bun test src/animation/Timeline.test.ts`)
- `cd src/zig && zig build` - Build Zig components (production)
- `cd src/zig && zig build -Doptimize=Debug` - Build Zig components (debug)
- `cd src/zig && zig build -Doptimize=ReleaseFast` - Build Zig components (optimized)

## Code Style

- **Runtime**: Bun with TypeScript
- **Formatting**: Prettier (semi: false, printWidth: 120)
- **Imports**: Use explicit imports, group by: built-ins, external deps, internal modules
- **Types**: Strict TypeScript, use interfaces for options/configs, explicit return types for public APIs
- **Naming**: camelCase for variables/functions, PascalCase for classes/interfaces, UPPER_CASE for constants
- **Error Handling**: Use proper Error objects, avoid silent failures
- **Async**: Prefer async/await over Promises, handle errors explicitly
- **Comments**: Minimal comments, focus on JSDoc for public APIs only
- **File Structure**: Index files for clean exports, group related functionality
- **Testing**: Bun test framework, descriptive test names, use beforeEach/afterEach for setup

## MoonBit Development

### Core Library Usage

**IMPORTANT**: MoonBit has an extensive core library. Always check and use existing implementations instead of creating custom ones.

#### Available Core Packages

The MoonBit core library (https://github.com/moonbitlang/core) provides these packages:

##### Data Structures

- **`array`** - Dynamic arrays with methods like `push`, `pop`, `map`, `filter`, `sort`, `shuffle`
- **`list`** - Immutable linked lists
- **`hashmap`** - Hash maps with `get`, `set`, `remove`, `contains`
- **`hashset`** - Hash sets for unique collections
- **`sorted_map`** - Ordered maps (B-tree based)
- **`sorted_set`** - Ordered sets
- **`deque`** - Double-ended queue
- **`queue`** - FIFO queue
- **`priority_queue`** - Priority queue/heap
- **`immut`** - Immutable/persistent data structures

##### Core Types

- **`ref`** - Mutable references (`Ref[T]`) - USE THIS instead of creating custom mutable wrappers
- **`option`** - Optional values (`Option[T]` or `T?`)
- **`result`** - Error handling (`Result[T, E]`)
- **`error`** - Error type utilities
- **`tuple`** - Tuple utilities

##### Primitive Extensions

- **`string`** - String manipulation
- **`bytes`** - Byte sequences
- **`buffer`** - Mutable byte buffers
- **`char`** - Character utilities
- **`int`**, **`int64`**, **`double`**, **`float`** - Numeric utilities
- **`bool`** - Boolean utilities

##### Utilities

- **`iter`** - Iterator patterns for functional programming
- **`json`** - JSON parsing and serialization
- **`random`** - Random number generation
- **`math`** - Mathematical functions
- **`encoding`** - Various encoding/decoding utilities
- **`strconv`** - String conversion utilities

##### Testing & Development

- **`test`** - Testing utilities
- **`quickcheck`** - Property-based testing
- **`coverage`** - Code coverage tools
- **`bench`** - Benchmarking utilities

### Usage Examples

**IMPORTANT UPDATE**: Many core types like `Ref`, `Option`, `Result` are built-in and don't need imports!

```moonbit
// Ref is built-in - no import needed!
let counter : Ref[Int] = Ref::new(0)
counter.val = counter.val + 1

// Option is built-in (? syntax)
fn find_user(id : String) -> User? {
  // Returns Some(user) or None
}

// For collections that aren't built-in, you may need to check if import is required
// HashMap seems to NOT be built-in and may need special handling
// Test first before assuming imports work

// Example of what DOESN'T work:
// import moonbitlang/core/hashmap  // This doesn't work in moon.pkg.json
// @hashmap.HashMap  // This syntax doesn't work either

// Instead, create your own simple Map implementation if needed
pub struct Map[V] {
  mut entries : Array[(String, V)]
}
```

### Import Pattern

In `moon.pkg.json`:

```json
{
  "import": [
    "moonbitlang/core/ref", // For mutable references
    "moonbitlang/core/option", // For optional values
    "moonbitlang/core/result", // For error handling
    "moonbitlang/core/hashmap", // For hash maps
    "moonbitlang/core/array", // For array utilities
    "moonbitlang/core/iter" // For iterators
  ]
}
```

### Best Practices

1. **Always check core library first** - Before implementing any data structure or utility
2. **Use `Ref[T]` for mutability** - Don't create custom mutable wrappers
3. **Use `Option[T]` for nullable** - Instead of custom Maybe types
4. **Use `Result[T, E]` for errors** - Instead of exceptions or custom error types
5. **Use core collections** - HashMap, HashSet, Queue, etc. instead of custom implementations
6. **Leverage iterators** - Use `iter` package for functional transformations

### Common Patterns

```moonbit
// Signal implementation using core Ref
import moonbitlang/core/ref

pub struct Signal[T] {
  value : Ref[T]  // Use core's Ref, not custom mutable wrapper
  listeners : Ref[Array[(T) -> Unit]]
}

// Error handling with Result
import moonbitlang/core/result

pub fn parse_config(data : String) -> Result[Config, ConfigError] {
  // Use Result for explicit error handling
}

// Collections with core types
import moonbitlang/core/hashmap
import moonbitlang/core/hashset

pub struct ComponentRegistry {
  components : @hashmap.HashMap[String, Component]
  active_ids : @hashset.HashSet[String]
}
```

### Documentation References

- Core Library Source: https://github.com/moonbitlang/core
- API Docs: https://mooncakes.io/docs/moonbitlang/core/
- Language Guide: Check moon-llm.txt in project root
# MoonBit Core Library Usage - IMPORTANT UPDATE

Based on our experience with the OneBit-TUI port, here's what we've learned about MoonBit's core library:

## Key Discovery: Built-in Types Don't Need Imports!

Many types from `moonbitlang/core` are **built-in** and work without any import statements:

### Built-in Types (No Import Needed)
- **`Ref[T]`** - Mutable references work directly
- **`Option[T]`** / **`T?`** - Optional types are built-in
- **`Result[T, E]`** - Error handling type (needs verification)
- **`Array[T]`** - Dynamic arrays are built-in
- **`FixedArray[T]`** - Fixed-size arrays are built-in

### Usage Without Imports

```moonbit
// ✅ CORRECT - No imports needed!
pub struct AppState {
  counter : Ref[Int]
  message : Ref[String?]
  items : Array[String]
}

pub fn example() {
  let state = Ref::new(42)
  state.val = 100
  
  let optional : String? = Some("hello")
  match optional {
    Some(s) => println(s)
    None => println("empty")
  }
}
```

### What DOESN'T Work

```moonbit
// ❌ INCORRECT - These imports don't work in moon.pkg.json
{
  "import": [
    "moonbitlang/core/ref",      // Doesn't work!
    "@moonbitlang/core/hashmap"  // Doesn't work!
  ]
}

// ❌ HashMap is NOT built-in
let map : HashMap[String, Int] = HashMap::new()  // Won't compile
```

### Workaround for Non-Built-in Types

For types like HashMap that aren't built-in, create your own simple implementation:

```moonbit
// Simple Map implementation when HashMap isn't available
pub struct Map[K, V] {
  mut entries : Array[(K, V)]
}

pub fn[K, V] Map::new() -> Map[K, V] {
  { entries: [] }
}

pub fn[K, V] Map::get(self : Map[K, V], key : K) -> V? {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, v) = self.entries[i]
    if k == key {
      return Some(v)
    }
  }
  None
}
```

## Recommendations

1. **Try using types directly first** - Don't assume you need imports
2. **Ref, Option, Array are definitely built-in** - Use them freely
3. **Create simple implementations** - For missing types like HashMap
4. **Test before importing** - The import system for core packages is unclear

## What We Still Don't Know

- How to properly import non-built-in core packages
- Which core types are built-in vs. which need imports
- Whether there's a way to use HashMap from core

This is based on practical experience from reducing 320 errors to 24 in the OneBit-TUI port.