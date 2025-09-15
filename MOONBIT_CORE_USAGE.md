# MoonBit Core Library Usage - IMPORTANT UPDATE

Based on our experience with the OneBit-TUI port, here's what we've learned:

## Key Discovery: Built-in Types Don't Need Imports!

Many types from moonbitlang/core are **built-in** and work without any import:

### Built-in Types (No Import Needed)
- **`Ref[T]`** - Mutable references
- **`Option[T]` / `T?`** - Optional types  
- **`Array[T]`** - Dynamic arrays
- **`FixedArray[T]`** - Fixed-size arrays
- **`Result[T, E]`** - Likely built-in (needs verification)

### Usage Without Imports

```moonbit
// ✅ CORRECT - No imports needed!
pub struct AppState {
  counter : Ref[Int]
  message : Ref[String?]
  items : Array[String]
}

let state = Ref::new(42)
state.val = 100
```

### What DOESN'T Work

```moonbit
// ❌ These imports fail
"moonbitlang/core/ref"      // Error: No matching module
"@moonbitlang/core/hashmap"  // Error: No matching module

// ❌ HashMap is NOT built-in
let map : HashMap[String, Int] = HashMap::new()  // Won't compile
```

### Workaround

Create your own simple implementations for missing types:

```moonbit
pub struct Map[K, V] {
  mut entries : Array[(K, V)]
}
```

## Recommendations

1. **Try using types directly first** - Don't assume imports are needed
2. **Ref, Option, Array are definitely built-in**
3. **Create simple implementations** for missing types
4. **The import system for core is unclear** - avoid it when possible

This is based on reducing 320 errors to 24 in the OneBit-TUI port!
