# MoonBit OpenTUI API Guide

This guide documents the MoonBit API patterns for the OpenTUI library, helping with demo migration and new development.

## Core Components Status ✅

All core components compile successfully with the following API:

### 1. Table Component

```moonbit
// Using builder pattern (recommended)
let table = @components.Table::builder[T]("table-id")
  .position(x, y)
  .size(width, height)
  .column("key", "Title", getter_fn, width)
  .build()

// Direct construction (for advanced use)
let columns = [
  {
    key: "id",
    title: "ID",
    width: 10,
    getter: fn(item) { item.id.to_string() },
    sortable: true,
    filterable: true,
    align: @core.TextAlign::Left
  }
]
let table = @components.Table::new("table-id", columns)

// Methods
table.set_data(items)
table.set_bounds(x, y, width, height)
table.render(buffer)
table.select_next_row()
table.select_previous_row()
table.sort_by_column(index)
table.set_filter(text, column_index?)
```

### 2. List Component

```moonbit
// Using builder pattern
let list = @components.List::builder(
  "list-id",
  items,
  fn(item) { item.to_string() }  // Display function
)
  .position(x, y)
  .size(width, height)
  .selected_index(0)
  .build()

// Methods
list.select_next()
list.select_previous()
list.get_selected_item()
list.render(buffer)
```

### 3. Tree Component

```moonbit
// Create nodes
let node = @components.TreeNode::new(
  "node-id",
  "Node Label",
  children~=[],       // Optional children
  expanded~=false,    // Optional expanded state
  data~=None         // Optional JSON data
)

// Create tree
let tree = @components.Tree::new(
  root_nodes,
  on_select~=None,   // Optional select handler
  on_expand~=None,   // Optional expand handler
  show_icons~=true   // Optional icon display
)

// Methods
tree.expand_node()
tree.collapse_node()
tree.select_next()
tree.select_previous()
tree.get_selected_node()
```

### 4. Toggle Component

```moonbit
let toggle = @components.Toggle::new(
  checked~=false,
  disabled~=false,
  label~="",
  on_change~=None
)

// Methods
toggle.set_checked(true)
toggle.is_checked()
toggle.handle_key(key)
```

### 5. TabSelect Component

```moonbit
let items = [
  { label: "Tab 1", value: "tab1", disabled: false },
  { label: "Tab 2", value: "tab2", disabled: false }
]

let tabs = @components.TabSelect::new(
  items,
  selected_index~=0,
  on_change~=None
)

// Methods
tabs.handle_key(key)
tabs.get_selected_value()
```

### 6. Modal Component

```moonbit
let modal = @components.Modal::new(
  "modal-id",
  "Title",
  "Content message"
)

// Methods
modal.show()
modal.hide()
modal.render(buffer)
```

### 7. Tooltip Component

```moonbit
let tooltip = @components.Tooltip::new(
  "Tooltip text",
  position~=@components.TooltipPosition::Above,
  max_width~=40
)

// Methods
tooltip.show_at(target_x, target_y, target_width, target_height)
tooltip.hide()
tooltip.set_text(text)
```

## Renderer and Terminal Control ✅

### Creating a Renderer

```moonbit
// Create renderer (returns Option)
let renderer = match @ffi.Renderer::new(width, height) {
  Some(r) => r
  None => panic("Failed to create renderer")
}

// Terminal control
renderer.clear_terminal()
renderer.resize(new_width, new_height)
renderer.set_terminal_title("My TUI App")

// Mouse and keyboard
renderer.enable_mouse(enable_movement~=false)
renderer.disable_mouse()
renderer.enable_kitty_keyboard(flags)

// Cursor control
renderer.set_cursor_position(x, y, visible)
renderer.set_cursor_style_ext("block", blinking~=true)
renderer.set_cursor_color_ext(r, g, b, a)

// Hit testing for mouse events
renderer.add_hit_region(x, y, width, height, component_id)
let hit_id = renderer.check_hit(mouse_x, mouse_y)

// Debug overlay
renderer.enable_debug_overlay(true, corner)
```

### Terminal Size and Resize Detection

```moonbit
// Get current terminal size
let (width, height) = @ffi.get_terminal_size()

// Install resize handler (call once at startup)
if @ffi.install_resize_handler() {
  println("Resize handler installed")
}

// Check for resize in your event loop
if @ffi.was_terminal_resized() {
  let (new_width, new_height) = @ffi.get_terminal_size()
  renderer.resize(new_width, new_height)
  // Recalculate layouts...
}

// Terminal session with auto-resize
let session = @ffi.TerminalSession::new(
  raw_mode~=true,
  mouse~=true,
  resize_detection~=true  // Auto-detect resize
)
```

## Buffer Operations ✅

```moonbit
// Create buffer
let buffer = @core.TerminalBuffer::new(width, height)

// Clear
buffer.clear()

// Write text
buffer.write_string(x, y, text, fg_color, bg_color, style)
buffer.write_char(x, y, char, fg_color, bg_color, style)

// Draw shapes
buffer.fill_rect(x, y, width, height, char, fg_color, bg_color, style)

// Get/set cells
let cell = buffer.get_cell(x, y)
buffer.set_cell(x, y, cell)

// Colors
let white = @core.RGBA::white()
let blue = @core.RGBA::blue()
let custom = @core.RGBA::rgb(0.5, 0.8, 1.0)

// Text styles
@core.TextStyle::None
@core.TextStyle::Bold
@core.TextStyle::Italic
@core.TextStyle::Underline
```

## Yoga Layout Integration ✅

```moonbit
// Using the wrapper API (recommended)
let root = @wrapper.Node::new()

// Set layout properties
root.set_width(100.0)
root.set_height(50.0)
root.set_flex_direction(@types.FlexDirection::Row)
root.set_justify_content(@types.JustifyContent::SpaceBetween)
root.set_align_items(@types.AlignItems::Center)
root.set_padding(@types.Edge::All, 10.0)

// Add children
let child1 = @wrapper.Node::new()
child1.set_flex_grow(1.0)
child1.set_margin(@types.Edge::Right, 5.0)

let child2 = @wrapper.Node::new()
child2.set_flex_grow(2.0)

root.add_child(child1)
root.add_child(child2)

// Calculate layout
root.calculate_layout(available_width, available_height, @types.Direction::LTR)

// Get computed layout
let layout = root.get_layout()  // Returns Layout { left, top, width, height }
let child1_layout = child1.get_layout()

// Apply to components
component.set_bounds(
  layout.left.to_int(),
  layout.top.to_int(),
  layout.width.to_int(),
  layout.height.to_int()
)
```

## Theme System ✅

```moonbit
// Built-in themes
let theme = @theming.Theme::dark()     // Default dark theme
let theme = @theming.Theme::light()    // Light theme
let theme = @theming.Theme::high_contrast()
let theme = @theming.Theme::solarized_dark()

// Access theme colors
theme.colors.primary    // Primary color
theme.colors.background // Background color
theme.colors.text      // Text color
theme.colors.border    // Border color

// Typography
theme.typography.font_size_base
theme.typography.line_height

// Spacing
theme.spacing.sm  // 8px
theme.spacing.md  // 12px
theme.spacing.lg  // 16px
```

## Event Loop (Simplified - Complex version has compiler issues)

```moonbit
// Create event loop
let event_loop = @core.EventLoop::new(frame_rate=60)

// Set renderer and root component
event_loop.set_renderer(renderer)
event_loop.set_root(root_component)

// Run (blocking)
event_loop.run()

// Stop
event_loop.stop()
```

## Input Handling (Ready but disabled due to compiler bug)

When re-enabled, the input system will provide:

```moonbit
// Parse input events
let event = @ffi.parse_input(input_bytes)

match event {
  @ffi.InputEvent::Key(char, ctrl, alt, shift) => {
    // Handle key press
  }
  @ffi.InputEvent::SpecialKey(key) => {
    match key {
      @ffi.SpecialKey::Up => // Arrow up
      @ffi.SpecialKey::Enter => // Enter key
      @ffi.SpecialKey::F(n) => // Function key
    }
  }
  @ffi.InputEvent::Mouse(x, y, action) => {
    match action {
      @ffi.MouseAction::Click(button) => // Mouse click
      @ffi.MouseAction::Move => // Mouse move
      @ffi.MouseAction::Scroll(delta) => // Mouse scroll
    }
  }
  @ffi.InputEvent::Resize(width, height) => {
    // Terminal resized
  }
}
```

## Migration Notes from TypeScript

### Key Differences

1. **No implicit type conversion** - Be explicit with `.to_int()`, `.to_string()`, etc.
2. **Labeled arguments** - Use `param~=value` syntax for optional parameters
3. **No tuple destructuring in for loops** - Use `for i, item in array` then destructure inside
4. **String methods** - Use `String::repeat(str, count)` not `str.repeat(count)`
5. **Array slicing** - Use `array[start:end].to_array()` for subarrays
6. **Option types** - Many functions return `Option[T]`, use pattern matching
7. **No exceptions** - Use `Result[T, E]` types for error handling

### Common Patterns

```moonbit
// Option handling
match renderer_opt {
  Some(r) => use_renderer(r)
  None => handle_error()
}

// Builder pattern (preferred)
let component = ComponentBuilder::new()
  .property1(value1)
  .property2(value2)
  .build()

// Method syntax
Type::method(instance, args)  // Static-like syntax
instance.method(args)         // Also works for some types

// Generic functions
fn[T] function_name(param : T) -> T
```

## Known Compiler Issues (v0.6.27)

The following features are implemented but disabled due to compiler bugs:

1. **Event loop with generic handlers** - `event_loop.mbt`
2. **Terminal I/O with complex parsing** - `terminal_io.mbt`
3. **Buffer bridge with type conversion** - `buffer_bridge.mbt`

These will be re-enabled once the compiler is fixed.

## Status Summary

- ✅ **Core Components**: All working
- ✅ **Renderer/FFI**: Basic features working
- ✅ **Yoga Layout**: Fully integrated
- ✅ **Theme System**: Complete with presets
- ✅ **Terminal Resize**: Detection and handling available
- ⚠️ **Event System**: Simplified version only (compiler bug)
- ⚠️ **Input Parsing**: Ready but disabled (compiler bug)
- ❌ **Demo Package**: Needs migration to new API (566 errors)
