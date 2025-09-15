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