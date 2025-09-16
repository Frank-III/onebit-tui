# MoonBit Language Learnings & Error Patterns

This document captures key learnings, common errors, and solutions discovered while developing the OneBit-TUI library in MoonBit.

## Table of Contents

1. [Type System & Traits](#type-system--traits)
2. [Visibility & Access Control](#visibility--access-control)
3. [Common Compilation Errors](#common-compilation-errors)
4. [FFI & C Interop](#ffi--c-interop)
5. [String Handling](#string-handling)
6. [Pattern Matching](#pattern-matching)
7. [Package System](#package-system)
8. [Best Practices](#best-practices)

## Type System & Traits

### Trait Implementation Syntax

**Key Pattern:** Use `impl` without `for`, just `impl TraitName for Type with`

```moonbit
// ✅ Correct - impl block syntax
impl ToChatCompletionMessageParamContent for String with
  to_chat_completion_message_param_content(self) -> Array[ContentPart] {
    [text_content_part(self)]
  }

// Also valid - pub impl for public implementations
pub impl ToJson for MyType with
  to_json(self) -> Json {
    Json::object({"key": self.value})
  }
```

### Traits Can Be Used as Types with References (&Trait)

**Key Discovery:** MoonBit supports trait objects using `&Trait` syntax (similar to Rust's `&dyn Trait`).

**Pattern:**

```moonbit
// ✅ Trait objects work with references!
struct Container {
  items : Array[&Renderable]  // This works!
}

// Usage with trait objects
let items : Array[&Shape] = [
  Rectangle::{ width: 10.0, height: 5.0 } as &Shape,
  Circle::{ radius: 5.0 } as &Shape
]

// Can call trait methods on trait objects
for item in items {
  println("Area: \{item.area()}")
}
```

**Object Safety Requirements:**
For a trait to be usable in a trait object (`&Trait`), methods must be object-safe:

- `self : T` should be the first parameter of the method
- Any other parameter of the method should not have the type `T`

**Alternative Solutions:**

1. **Use Generic Type Parameters with Trait Bounds:**

```moonbit
// ✅ Generic with trait bound (static dispatch)
struct Container[T : Renderable] {
  item : T
}
```

2. **Create Concrete Wrapper Types:**

```moonbit
// ✅ Concrete wrapper for heterogeneous collections
enum ComponentType {
  Box(Box)
  Text(Text)
}
```

## Visibility & Access Control

### pub vs pub(all)

**Key Discovery:** `pub` makes items read-only across packages, while `pub(all)` provides full public access.

**Error Pattern:**

```moonbit
// In package A
pub struct MyStruct {
  value : Int
}

// In package B
let s = @packageA.MyStruct::{ value: 10 }
// Error: Cannot create values of the read-only type
```

**Solution:**

```moonbit
// In package A
pub(all) struct MyStruct {  // Use pub(all) for cross-package creation
  value : Int
}
```

### Read-only enum variants in tests (cross-package)

**Symptom:** Tests compiled as a separate package (e.g., `core_blackbox_test`) cannot construct enum variants from the library package even if the enum is `pub`.

```moonbit
// ❌ From test package
let v = @core.JustifyContent::Start
// Error [4036]: Cannot create values of the read-only type: Start.
```

**Workarounds:**

- Prefer defaulted parameters in constructors and omit explicit enum values in tests.
- Or expose factory helpers in the library (e.g., `JustifyContent::start() -> JustifyContent`).
- Long-term: promote to `pub(all)` if cross-package construction is intended.

### Mutable Fields

**Error Pattern:**

```moonbit
pub struct State {
  count : Int
}

fn increment(state : State) -> Unit {
  state.count = state.count + 1  // Error: Cannot modify read-only field
}
```

**Solution:**

```moonbit
pub struct State {
  mut count : Int  // Mark field as mutable
}
```

## Common Compilation Errors

### Error [4051]: Duplicate Definitions

**Pattern:** Types and functions must have unique names within a package.

```moonbit
// file1.mbt
struct FileNode { ... }
fn format_size() { ... }

// file2.mbt in same package
struct FileNode { ... }  // Error: FileNode is declared twice
fn format_size() { ... }  // Error: format_size is declared twice
```

**Solution:** Use unique names or prefixes:

```moonbit
// file1.mbt
struct MockFileNode { ... }
fn format_size_mock() { ... }

// file2.mbt
struct RealFileNode { ... }
fn format_size_real() { ... }
```

### Error [4031]: Undefined Constructor

**Pattern:** Trying to use a constructor that doesn't exist in an enum.

```moonbit
// Error example
@ffi.KeyEvent::Space  // Error if Space is not defined

// Solution: Use the correct constructor
@ffi.KeyEvent::Char(32)  // Space key as ASCII value
```

### Error [4014]: Type Mismatch

**Pattern:** Using deprecated methods that return Option types.

```moonbit
// Deprecated pattern
if filename.ends_with(".txt") { }  // Returns Option, not Bool

// Solution
if filename.strip_suffix(".txt").is_some() { }
```

### Error [3002]: Indentation Issues

**Pattern:** MoonBit is indentation-sensitive for certain constructs.

```moonbit
// Error: Not left-aligned
             if condition { "yes" } else { "no" }

// Solution: Wrap in parentheses
let result = (if condition { "yes" } else { "no" })
```

### Error [0015]: Unused Mutability

**Pattern:** Declaring a field as mutable but never modifying it.

```moonbit
struct Data {
  mut value : Int  // Warning if never modified
}

// Solution: Remove mut if not needed
struct Data {
  value : Int
}
```

## FFI & C Interop

### Pointer Ownership Annotations

**Warning Pattern:**

```moonbit
extern "C" fn someFunction(ptr : PointerType) -> Unit
// Warning: Should annotate with #borrow or #owned
```

**Best Practice (future-proofing):**

```moonbit
extern "C" fn someFunction(#borrow ptr : PointerType) -> Unit
// or
extern "C" fn someFunction(#owned ptr : PointerType) -> Unit
```

### CSI Escape Sequence Parsing

**Key Learning:** Arrow keys and special keys come as escape sequences that need careful parsing.

```moonbit
// Pattern for parsing arrow keys
fn parse_csi_sequence(buffer : Bytes, start : Int, available : Int) -> InputEvent {
  // Arrow keys: ESC[A, ESC[B, ESC[C, ESC[D
  let final_char = buffer[start + available - 1]
  match final_char {
    65 => InputEvent::Key(KeyEvent::ArrowUp)      // A
    66 => InputEvent::Key(KeyEvent::ArrowDown)    // B
    67 => InputEvent::Key(KeyEvent::ArrowRight)   // C
    68 => InputEvent::Key(KeyEvent::ArrowLeft)    // D
    _ => InputEvent::Key(KeyEvent::Unknown)
  }
}
```

### Linking: tests vs binaries vs non-main packages

**Symptoms observed:**

- Tests failing with undefined symbols when using relative `cc-link-flags` (paths resolve from test directories).
- `moon run` or `moon build` at package root sometimes tries to link non-main packages, causing `_main` undefined errors.

**Fixes/Patterns:**

- Prefer `"link": { "native": { "cc": "clang", "cc-link-flags": "-L<abs> -l<lib> ..." } }` over relative `.a` paths; use absolute `-L` and `-l`.
- For packages that produce a main (examples/demos/tests), declare their own link flags; flags do not propagate automatically.
- For demos, run the compiled binary directly (more reliable than generic `moon run` in mixed packages).
- If dynamic libs are used, add rpath: `-Wl,-rpath,<path>`.

### MoonBit pointer ownership warnings

**Pattern:** Warnings for pointer params without `#borrow`/`#owned` in extern declarations.

**Action:** Annotate where safe to future-proof ABI expectations. Not a functional blocker but recommended.

### TTY requirements for interactive demos

**Observation:** Raw mode/read input fails in non-interactive environments (no TTY), demos appear and exit quickly.

**Mitigation:**

- Run interactive demos in a real terminal.
- For visual-only demos, use a short event loop that exits on keypress or timeout.

## Yoga Integration Notes

### Int → Float conversions for Yoga

**Issue:** Yoga setters expect `Float`, while view bounds are `Int`.

**Pattern used:** Chain conversions: `int.to_double().to_float()` before calling Yoga setters.

### Box/Padding with Yoga

**Approach:**

- Box: subtract border/title from outer rect to compute inner area; pass padding to Yoga; lay out children via Yoga nodes; still draw border/title via FFI.
- Padding: wrap child in Yoga node with `set_padding_all` to compute inner rect consistently.

### Flattened layout for hit-testing

**Utility:** `flatten_layout(view, bounds)` recursively builds a Yoga tree and returns leaf rectangles for selection/hit-testing overlays.

## Build & Tooling

### Scoped examples to avoid test pollution

**Problem:** Experimental examples in `src/examples.disabled` were compiled in aggregate, causing parse errors.

**Solution:**

- Disable the package (`moon.pkg.json.disabled`) or move to a playground folder.
- Rename out-of-date tests to `.disabled` until API stabilized.

### Justfile recipes for reliability

**Findings:**

- Running the compiled demo binary is more deterministic than `moon run` when multiple packages exist.
- `run-interactive` should call the interactive entrypoint directly to avoid default-demo changes.
- Some workspaces see `moon build -C <pkg>` attempt to link non-main dependencies; guard recipes with a leading `-` to ignore non-fatal link failures, and then run the produced binary if present.

## String Handling

### String Splitting

**Key Pattern:** `split()` returns an iterator, not an array. You must collect it manually.

```moonbit
// ❌ Wrong - split doesn't return Array
let lines : Array[String] = content.split("\n")

// ✅ Correct - collect iterator into array
let mut lines : Array[String] = []
let iter = content.split("\n")  // Use string literal "\n" not char '\n'
iter.each(fn(line) { lines.push(line.to_string()) })

// Alternative using for-in (if supported)
let mut lines : Array[String] = []
for line in content.split("\n") {
  lines.push(line.to_string())
}
```

### No Direct Substring Method

**Error Pattern:**

```moonbit
let sub = str.substring(0, 5)  // Method doesn't exist with this signature
```

**Solution:**

```moonbit
// Use substring with named parameters
let sub = str.substring(start=0, end=5)

// Or for removing from end
let shortened = str.substring(end=str.length() - 1)

// Manual character iteration (if substring not available)
let mut result = ""
for i = 0; i < 5 && i < str.length(); i = i + 1 {
  result = result + str[i].to_string()
}
```

### String Comparison with strip_suffix

**Pattern:** Use `strip_suffix` instead of deprecated `ends_with`.

```moonbit
// Check file extension
if filename.strip_suffix(".mbt").is_some() {
  // It's a MoonBit file
}
```

## Struct Construction

### Struct Literal Syntax

**Key Learning:** MoonBit can infer struct types from context, no need for explicit type prefix.

```moonbit
struct Point { x : Int, y : Int }

// ❌ Wrong - DON'T use Type:: prefix with struct literals
let p = Point::{ x: 10, y: 20 }  // This is INCORRECT syntax!

// ✅ Correct - just use curly braces
let p : Point = { x: 10, y: 20 }

// ✅ Also works when type is obvious from context
fn take_point(p : Point) -> Unit { ... }
take_point({ x: 10, y: 20 })  // Type inferred from function signature

// ✅ In arrays with type annotation
let points : Array[Point] = [
  { x: 0, y: 0 },
  { x: 10, y: 10 }
]

// ✅ In function returns - type inference works
fn make_point() -> Point {
  { x: 10, y: 20 }  // No prefix needed
}

// ✅ In constructor functions
pub fn Rect::new(x : Int, y : Int, width : Int, height : Int) -> Rect {
  { x, y, width, height }  // Just braces, no Rect:: prefix
}

// ✅ Using match expressions for optional fields in struct construction
struct Migrator {
  repo : String
  max_while_loop : Int
}

let migrator = Migrator::{
  repo: "my-repo",
  max_while_loop: match arguments.max_while_loop {
    None => 1
    Some(max_while_loop) => max_while_loop
  }
}

// IMPORTANT PATTERN:
// When you see "Type::{" in code, ALWAYS remove the "Type::" part
// MoonBit struct literals NEVER use the Type:: prefix
// EXCEPTION: Type::{} syntax IS valid for struct construction with labeled fields
```

## Pattern Matching

### Matching on Enums

```moonbit
enum Direction {
  Up
  Down
  Left
  Right
}

// Pattern matching
match direction {
  Direction::Up => move_up()
  Direction::Down => move_down()
  Direction::Left | Direction::Right => move_horizontal()  // Multiple patterns
}
```

### Matching with Guards (Not Supported)

**Note:** Guard clauses in pattern matching don't seem to be supported.

```moonbit
// This pattern doesn't work in MoonBit
match value {
  n if n > 10 => ...  // Guards not supported
  _ => ...
}

// Use nested if instead
match value {
  n => if n > 10 { ... } else { ... }
}
```

## Package System

### Import Syntax

```moonbit
// Import from another package in the same project
@package_name.TypeName
@package_name.function_name()

// Import from external packages
@fs.read_file_to_string(path)

// Example
@core.BaseRenderable
@ffi.Buffer
```

### Package Structure

```
src/
  core/
    moon.pkg.json     # Package configuration
    types.mbt         # Module files
  components/
    moon.pkg.json
    box.mbt
  demo/
    moon.pkg.json
    main.mbt         # Entry point (has fn main)
```

### Adding External Dependencies

1. **Add dependency to moon.mod.json:**

```bash
moon add moonbitlang/x  # Adds the package
```

This updates `moon.mod.json`:

```json
{
  "deps": {
    "moonbitlang/x": "0.4.32"
  }
}
```

2. **Import specific subpackages in moon.pkg.json:**

```json
{
  "import": [
    "moonbit-community/onebit-tui/core",
    "moonbitlang/x/fs" // Import specific subpackage
  ]
}
```

**Note:** moonbitlang/x contains multiple subpackages (fs, json, etc.). You import the specific ones you need.

### Cross-Package Dependencies

In `moon.pkg.json`:

```json
{
  "import": ["moonbit-community/onebit-tui/core", "moonbit-community/onebit-tui/ffi"]
}
```

## Best Practices

### 1. Prefer Composition Over Trait Objects

Since traits can't be used as types directly, design APIs around concrete types or generics.

### 2. Use pub(all) for Library APIs

When creating libraries, use `pub(all)` for types that users need to instantiate.

### 3. Handle Option Types Explicitly

Many MoonBit methods return Option types. Always handle them explicitly:

```moonbit
match optional_value {
  Some(v) => process(v)
  None => handle_none()
}
```

### 4. Function Type Signatures

Remove parameter names in function type definitions:

```moonbit
// ❌ Wrong
type Handler = (buffer : Buffer, x : Int) -> Unit

// ✅ Correct
type Handler = (Buffer, Int) -> Unit
```

### 5. Numeric Type Conversions

Be explicit with numeric conversions:

```moonbit
let int_val = 42
let uint_val = int_val.reinterpret_as_uint()
let double_val = int_val.to_double()
```

### 6. Missing Standard Methods

Some expected methods might not exist on basic types:

- `Double` doesn't have `min()` or `max()` methods
- Use conditional expressions instead:

```moonbit
let clamped = if value < 0.0 { 0.0 }
              else if value > 1.0 { 1.0 }
              else { value }
```

### 7. Array Iteration

```moonbit
// Fixed arrays
let arr = FixedArray::make(10, 0)
for i = 0; i < arr.length(); i = i + 1 {
  arr[i] = i * 2
}

// Dynamic arrays
let arr = Array::new()
arr.push(value)
```

### 8. Error Handling with Try-Catch

```moonbit
try {
  @fs.read_file_to_string(path)
} catch {
  @fs.IOError(msg) => {
    println("Error: " + msg)
    ""  // Return default value
  }
}
```

## Deprecated Patterns to Avoid

1. **Old polymorphic function syntax:**

```moonbit
// ❌ Deprecated
pub fn Table::new[T](columns : Array[Column[T]]) -> Table[T]

// ✅ New syntax
pub fn[T] Table::new(columns : Array[Column[T]]) -> Table[T]
```

2. **Using ends_with for strings:**

```moonbit
// ❌ Deprecated
if str.ends_with(".txt")

// ✅ Use strip_suffix
if str.strip_suffix(".txt").is_some()
```

3. **Math functions on numeric types:**

```moonbit
// ❌ Deprecated
value.sin()

// ✅ Use @math module
@math.sin(value)
```

## Debugging Tips

1. **Use moon build frequently** - Compile often to catch errors early
2. **Check visibility modifiers** - Most cross-package errors are visibility-related
3. **Read error codes** - MoonBit error codes are well-categorized:
   - 0xxx: Warnings
   - 3xxx: Syntax/formatting errors
   - 4xxx: Type errors
   - Others: Various semantic errors

4. **When stuck, check:**
   - Is the field mutable? (needs `mut`)
   - Is the type visible? (needs `pub` or `pub(all)`)
   - Is the method deprecated? (check warnings)
   - Is it a trait being used as a type? (use generics or wrapper)

## Future Investigations

1. **Reference types with traits** - Can we use `&Trait` similar to Rust's `&dyn Trait`?
2. **Async/await support** - Does MoonBit have async capabilities?
3. **Macro system** - Are there macros or code generation tools?
4. **Reflection** - Runtime type information availability?
5. **Package versioning** - How to handle breaking changes in dependencies?

## Useful Commands

```bash
# Build project
moon build --target native

# Run tests
moon test

# Generate package info (for .mbti files)
moon info

# Check package
moon check

# Format code
moon fmt
```

## Cross-Package Visibility for Enums and Structs

### Problem: Read-only Types Across Packages

When a struct or enum is marked as `pub`, it's visible but read-only in other packages. You can't create instances.

**Error Examples:**

```moonbit
// In components package
pub struct ModalConfig { ... }
pub enum BorderStyle { Single; Double }

// In demo package - ERRORS!
let config = @components.ModalConfig::{ ... }  // Error [4036]: Cannot create values of read-only type
let style = @components.BorderStyle::Single    // Error [4036]: Cannot create values of read-only type
```

**Solution: Use pub(all)**

```moonbit
// In components package
pub(all) struct ModalConfig { ... }  // Now can be instantiated anywhere
pub(all) enum BorderStyle { Single; Double }  // Variants can be used anywhere
```

## Optional Parameters in MoonBit

### Struct Fields

```moonbit
// Correct: Option types for optional fields
pub struct Config {
  title : String
  width : Int?      // Optional field
  on_close : (() -> Unit)?  // Optional callback
}
```

### Function Parameters

```moonbit
// For optional parameters, use Option type
pub fn modal(config : Config, on_cancel : (() -> Unit)?) -> View

// Call with Some or None
modal(config, Some(fn() { ... }))
modal(config, None)
```

## Resources

- MoonBit documentation: Check moon-llm.txt in project
- Official packages: moonbitlang/x/\* (like fs, json, etc.)
- Error codes: Well-documented in compiler output

---

_This document is a living reference. Update it as new patterns and solutions are discovered._
