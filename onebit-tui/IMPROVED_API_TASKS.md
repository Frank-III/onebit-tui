# Tasks to Improve OneBit-TUI API

## Current Problems with MoonBit Implementation

### 1. ❌ Magic Numbers Everywhere

```moonbit
// BAD - What do these numbers mean?
if key == 113 || key == 27 { }  // 'q' or ESC
if key == 65 { }  // Up arrow??
```

### 2. ❌ Manual Buffer Operations

```moonbit
// BAD - Too low-level, error-prone
buffer.write_string(x, y, text, fg_color, bg_color, style)
buffer.fill_rect(x, y, w, h, ' ', fg, bg, style)
```

### 3. ❌ Verbose Component Creation

```moonbit
// BAD - Too much boilerplate
let list = List::new("id", items)
list.selected_index = 0
list.border_style = BorderStyle::Single
list.border_color = RGBA::white()
list.text_color = RGBA::white()
```

### 4. ❌ No Proper Event System

```moonbit
// BAD - Polling with magic sleep times
while running {
  if @ffi.is_input_available() {
    let key = @ffi.read_key_byte()
    // Manual key handling...
  }
  @ffi.sleep_ms(16)  // Magic number for 60 FPS
}
```

## Tasks to Fix These Issues

### ✅ Task 1: Create Proper Key/Event Enums

**Priority: HIGH**
**File**: `src/core/keys.mbt`
**Status**: COMPLETED

```moonbit
pub enum Key {
  Char(Char)
  Enter
  Tab
  Escape
  Backspace
  Delete
  Up
  Down
  Left
  Right
  Home
  End
  PageUp
  PageDown
  F(Int)  // F1-F12
}

pub enum MouseButton {
  Left
  Right
  Middle
}

pub enum Event {
  Key(Key)
  Mouse { x: Int, y: Int, button: MouseButton, action: MouseAction }
  Resize { width: Int, height: Int }
}
```

### 🎯 Task 2: Component Builder Pattern

**Priority: HIGH**
**Files**: Update all components in `src/components/`

```moonbit
// Make ALL components use builder pattern
pub fn List::builder() -> ListBuilder {
  ListBuilder::new()
    .items(items)
    .selected(0)
    .border(BorderStyle::Single)
    .on_select(fn(item) { ... })
    .build()
}
```

### ✅ Task 3: High-Level App Wrapper

**Priority: HIGH**
**File**: `src/core/app.mbt`
**Status**: COMPLETED

```moonbit
pub struct App {
  mut root : View
  mut running : Bool
  event_handlers : HashMap[Event, fn() -> Unit]
}

pub fn App::new() -> App {
  // Handle ALL terminal setup internally
}

pub fn App::run(self : App) -> Unit {
  // Handle event loop, rendering, cleanup
}
```

### 🎯 Task 4: Declarative UI Tree

**Priority: MEDIUM**
**File**: `src/core/ui.mbt`

```moonbit
// Clean component composition
let ui = vstack()
  .spacing(1)
  .children([
    text("Hello World").color(Color::Yellow),
    hstack().children([
      button("OK").on_click(handle_ok),
      spacer(),
      button("Cancel").on_click(handle_cancel)
    ])
  ])
```

### 🎯 Task 5: Signal-Based Reactivity

**Priority: MEDIUM**
**File**: `src/reactive/signals.mbt`

```moonbit
let selected = Signal::new(0)
let items = Signal::new(["Item 1", "Item 2"])

// Components auto-update when signals change
list()
  .items(items)
  .selected(selected)
  .on_change(fn(idx) { selected.set(idx) })
```

### 🎯 Task 6: Style System

**Priority: LOW**
**File**: `src/core/theme.mbt`

```moonbit
struct Theme {
  primary : Color
  secondary : Color
  background : Color
  text : Color
  border : BorderStyle
}

// Apply theme to whole app
app.set_theme(Theme::dark())
```

## Working Demos to Fix

Based on the demos, these should be relatively easy to get working:

### 1. ✅ `baserenderable_demo.mbt`

- Shows basic component composition
- Just needs API updates
- **Updated**: Created `baserenderable_demo_updated.mbt` with App wrapper

### 2. ✅ `animation_demo.mbt`

- Shows animation system
- Needs Timeline fixes

### 3. ✅ `select_demo.mbt`

- Interactive select component
- Needs key enum fixes

## Implementation Order

1. **First**: Fix key handling (Task 1) ✅ DONE
   - Created Key enum
   - Added from_byte() conversion
2. **Second**: Create App wrapper (Task 3) ✅ DONE
   - Hides terminal complexity
   - Clean builder pattern API
   - Automatic setup/teardown
3. **Third**: Add builder pattern to components (Task 2) 🎯 NEXT
   - Start with List, Select, Box
   - Make consistent API
4. **Then**: Declarative UI (Task 4)
   - Component composition
   - Layout helpers

## Example: What a Clean Demo Should Look Like

```moonbit
fn main() {
  App::new()
    .title("Todo App")
    .on_key(Key::Char('q'), fn(app) { app.quit() })
    .render(fn(state) {
      box()
        .title("Todo List")
        .border(BorderStyle::Double)
        .child(
          vstack()
            .children([
              text("My Tasks").bold(),
              list()
                .items(state.todos)
                .on_select(fn(item) {
                  state.toggle_todo(item)
                }),
              hstack()
                .children([
                  button("Add").on_click(fn() { state.add_todo() }),
                  spacer(),
                  button("Clear").on_click(fn() { state.clear_todos() })
                ])
            ])
        )
    })
    .run()
}
```

## Success Metrics

A good API should:

- ✅ No magic numbers
- ✅ No manual buffer operations
- ✅ Declarative and composable
- ✅ Type-safe
- ✅ Minimal boilerplate
- ✅ Familiar to React/Solid developers
- ✅ Good error messages
- ✅ Easy to test

## Completed Tasks

1. ✅ Created Key enum in `src/core/keys.mbt`
2. ✅ Created App wrapper in `src/core/app.mbt`
3. ✅ Created `simple_app_demo.mbt` showing clean API
4. ✅ Updated `baserenderable_demo_updated.mbt` with new patterns

## Next Steps

1. 🎯 Add builder pattern to core components (List, Select, Box)
2. 🎯 Update remaining demos to use App wrapper
3. 🎯 Fix FFI/linking issues to get builds working
4. 📝 Document the new patterns
5. 🗑️ Deprecate old APIs
