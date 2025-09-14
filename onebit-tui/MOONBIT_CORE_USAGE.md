# MoonBit Core Library Usage Guide for OneBit-TUI

This guide helps developers understand which MoonBit core library packages to use instead of creating custom implementations.

## ✅ Use Core Library Instead Of Custom Implementation

### Mutable State Management

```moonbit
// ❌ DON'T: Create custom mutable wrapper
struct MutableValue[T] {
  mut value : T
}

// ✅ DO: Use Ref from core
import moonbitlang/core/ref
let state : Ref[T] = Ref::new(initial_value)
state.val = new_value
```

### Collections

```moonbit
// ❌ DON'T: Implement custom HashMap
struct MyHashMap[K, V] { ... }

// ✅ DO: Use core collections
import moonbitlang/core/hashmap
import moonbitlang/core/hashset
import moonbitlang/core/queue
import moonbitlang/core/deque

let components = @hashmap.HashMap::new()
let event_queue = @queue.Queue::new()
let history = @deque.Deque::new()
```

### Optional Values

```moonbit
// ❌ DON'T: Create custom Maybe type
enum Maybe[T] {
  Just(T)
  Nothing
}

// ✅ DO: Use Option from core
import moonbitlang/core/option
fn find_component(id : String) -> Component? {
  // Returns Some(component) or None
}
```

### Error Handling

```moonbit
// ❌ DON'T: Use exceptions or panic
fn parse(s : String) -> Int {
  abort("parse error")  // Bad!
}

// ✅ DO: Use Result type
import moonbitlang/core/result
fn parse(s : String) -> Result[Int, ParseError] {
  // Returns Ok(value) or Err(error)
}
```

## 📦 Core Packages for OneBit-TUI

### Essential Imports

```json
// moon.pkg.json
{
  "import": [
    // State management
    "moonbitlang/core/ref", // Mutable references

    // Error handling
    "moonbitlang/core/option", // Optional values
    "moonbitlang/core/result", // Error as values

    // Collections
    "moonbitlang/core/array", // Dynamic arrays
    "moonbitlang/core/hashmap", // Component registry
    "moonbitlang/core/hashset", // Unique collections
    "moonbitlang/core/queue", // Event queue
    "moonbitlang/core/deque", // History/undo

    // Functional programming
    "moonbitlang/core/iter", // Iterators

    // Data interchange
    "moonbitlang/core/json", // Configuration

    // Utilities
    "moonbitlang/core/string", // String manipulation
    "moonbitlang/core/bytes", // Terminal I/O
    "moonbitlang/core/buffer" // Rendering buffer
  ]
}
```

## 🔄 Migration Examples

### Before (Custom Implementation)

```moonbit
// Custom signal implementation
struct Signal[T] {
  mut value : T
  mut listeners : Array[(T) -> Unit]
}

// Custom event queue
struct EventQueue {
  mut events : Array[Event]
  mut head : Int
  mut tail : Int
}

// Custom component map
struct ComponentMap {
  mut buckets : Array[Array[(String, Component)]]
}
```

### After (Using Core Library)

```moonbit
import moonbitlang/core/ref
import moonbitlang/core/queue
import moonbitlang/core/hashmap

// Signal using core Ref
pub struct Signal[T] {
  value : Ref[T]
  listeners : Ref[Array[(T) -> Unit]]
}

// Event queue using core Queue
pub struct EventSystem {
  queue : @queue.Queue[Event]
}

// Component registry using core HashMap
pub struct ComponentRegistry {
  components : @hashmap.HashMap[String, Component]
}
```

## 🎯 Specific Use Cases

### 1. Reactive State (use `Ref`)

```moonbit
import moonbitlang/core/ref

pub struct ReactiveValue[T] {
  value : Ref[T]
  version : Ref[Int]  // Track changes
}
```

### 2. Component Tree (use `HashMap` + `Array`)

```moonbit
import moonbitlang/core/hashmap
import moonbitlang/core/array

pub struct ComponentTree {
  nodes : @hashmap.HashMap[String, Component]
  children : @hashmap.HashMap[String, Array[String]]
  parent : @hashmap.HashMap[String, String?]
}
```

### 3. Event Processing (use `Queue` + `Result`)

```moonbit
import moonbitlang/core/queue
import moonbitlang/core/result

pub fn process_events(
  queue : @queue.Queue[Event]
) -> Result[Unit, ProcessError] {
  while not(queue.is_empty()) {
    let event = queue.pop_front()?
    handle_event(event)?
  }
  Ok(())
}
```

### 4. Rendering Buffer (use `Buffer`)

```moonbit
import moonbitlang/core/buffer

pub struct RenderBuffer {
  content : @buffer.T
  width : Int
  height : Int
}

pub fn RenderBuffer::write_at(
  self : RenderBuffer,
  x : Int,
  y : Int,
  text : String
) -> Unit {
  let offset = y * self.width + x
  self.content.write_string(text)
}
```

### 5. Focus Management (use `Option`)

```moonbit
import moonbitlang/core/option
import moonbitlang/core/ref

pub struct FocusManager {
  current : Ref[String?]  // Currently focused component ID
  history : @deque.Deque[String]  // Focus history
}

pub fn FocusManager::focus(self : FocusManager, id : String) -> Unit {
  match self.current.val {
    Some(prev) => self.history.push_back(prev)
    None => ()
  }
  self.current.val = Some(id)
}
```

## ⚠️ Common Pitfalls

1. **Don't reimplement Ref** - It's already optimized and well-tested
2. **Don't create custom Option/Result** - Use the standard ones for ecosystem compatibility
3. **Don't write custom hash functions** - Use the Hash trait from core
4. **Don't implement custom iterators** - Use and extend core's Iter type
5. **Don't create custom JSON parsers** - Use moonbitlang/core/json

## 📚 Further Reading

- [MoonBit Core Library Source](https://github.com/moonbitlang/core)
- [Core Library API Docs](https://mooncakes.io/docs/moonbitlang/core/)
- [MoonBit Language Guide](../moon-llm.txt)
- [MoonBit Learnings](./MOONBIT_LEARNINGS.md)

## 🚀 Quick Reference

| Need           | Use Core Package    | Import                     |
| -------------- | ------------------- | -------------------------- |
| Mutable value  | `Ref[T]`            | `moonbitlang/core/ref`     |
| Optional value | `Option[T]` or `T?` | `moonbitlang/core/option`  |
| Error handling | `Result[T, E]`      | `moonbitlang/core/result`  |
| Dynamic array  | `Array[T]`          | `moonbitlang/core/array`   |
| Hash map       | `HashMap[K, V]`     | `moonbitlang/core/hashmap` |
| Hash set       | `HashSet[T]`        | `moonbitlang/core/hashset` |
| Queue          | `Queue[T]`          | `moonbitlang/core/queue`   |
| Stack          | `Deque[T]`          | `moonbitlang/core/deque`   |
| JSON           | `Json`              | `moonbitlang/core/json`    |
| String builder | `Buffer`            | `moonbitlang/core/buffer`  |
| Iterators      | `Iter[T]`           | `moonbitlang/core/iter`    |

Remember: **Always check the core library first!**
