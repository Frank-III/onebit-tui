# OneBit-TUI

A modern terminal user interface library for MoonBit, featuring declarative components, Yoga-powered flexbox layout, and high-performance native rendering.

## Features

- 🎨 **Declarative API** - Build UIs with composable View components
- 📐 **Flexbox Layout** - Powered by Yoga layout engine for responsive designs
- ⚡ **Native Performance** - Leverages Zig-based renderer for optimal performance
- 🖼️ **Rich Borders** - Unicode box-drawing with customizable styles
- 📜 **Overflow Handling** - Built-in scrolling and clipping support
- ⌨️ **Input Handling** - Full keyboard and mouse event support
- 🎯 **Focus Management** - Automatic focus traversal and highlighting

## Installation

```bash
moon add Frank-III/onebit-tui
```

**Note**: First-time setup requires building the native renderer:

```bash
cd $HOME/.moon/lib/Frank-III/onebit-tui
./build_ffi.sh
```

## Quick Start

```moonbit
///| Simple counter app
fn main {
  let app = @core.App::init()
  match app {
    None => println("Failed to initialize")
    Some(app) => {
      let counter = Ref::new(0)

      fn build_ui() -> @view.View {
        @view.View::container_views([
          @view.View::text("Count: \{counter.val}", color=@core.Color::White),
          @view.View::text("Press +/- to change", color=@core.Color::Gray)
        ])
        .direction(@view.Direction::Column)
        .padding(2.0)
        .border(@view.BorderStyle::Single, color=@core.Color::Cyan)
        .title("Counter")
        .title_align(@view.TitleAlign::Center)
      }

      @runtime.run_event_loop(app, build_ui, fn(event) {
        match event {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(43)) => { // '+'
            counter.val = counter.val + 1
            true
          }
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(45)) => { // '-'
            counter.val = counter.val - 1
            true
          }
          _ => false
        }
      })

      app.cleanup()
    }
  }
}
```

## Core Concepts

### Views

Views are the building blocks of OneBit-TUI applications:

```moonbit
// Text view
@view.View::text("Hello, World!", color=@core.Color::Green)

// Container with children
@view.View::container_views([
  child1,
  child2,
])
.direction(@view.Direction::Row)
.spacing(1.0)
```

### Layout (Yoga Flexbox)

OneBit-TUI uses Yoga for powerful flexbox layout:

```moonbit
view
  .width(50.0)                    // Fixed width
  .height_percent(50.0)           // 50% of parent height
  .flex(1.0)                      // Flex grow
  .padding(2.0)                   // Padding on all sides
  .margin_symmetric(1.0, 2.0)    // Vertical, horizontal margins
  .align_items(@types.Align::Center)
  .justify_content(@types.Justify::SpaceBetween)
```

### Styling

```moonbit
view
  .border(@view.BorderStyle::Double, color=@core.Color::Cyan)
  .title("My Box")
  .title_align(@view.TitleAlign::Center)
  .background(@core.rgb(20, 20, 40))
  .foreground(@core.Color::White)
  .focused_border_color(@core.Color::Yellow)
```

## Built-in Widgets

### List Widget

```moonbit
let items = ["Item 1", "Item 2", "Item 3"]
let selected = Ref::new(0)
let list = @widget.List::new(items, selected)
  .item_renderer(fn(item, index, is_selected) {
    let prefix = if is_selected { "> " } else { "  " }
    prefix + item
  })
```

### Text Input

```moonbit
let text_value = Ref::new("")
let input = @widget.TextInput::new(text_value)
  .placeholder("Enter text...")
  .width(30.0)
```

### Button

```moonbit
let button = @widget.Button::new("Click Me", fn() {
  println("Button clicked!")
})
```

### Progress Bar

```moonbit
let progress = @widget.ProgressBar::new(0.5, style=@widget.ProgressStyle::blocks())
  .width(40.0)
```

### ScrollBox

```moonbit
let items = generate_many_items()
let scroll = @widget.ScrollBox::new(items, visible_rows=10)
  .border(@view.BorderStyle::Single)
  .title("Scrollable List")
```

## Event Handling

```moonbit
// Global event handler
fn on_global_event(event : @ffi.InputEvent) -> Bool {
  match event {
    Key(Escape) => false  // Exit app
    MouseDown(x, y, button) => {
      println("Click at \{x}, \{y}")
      true
    }
    Resize(width, height) => {
      println("Terminal resized to \{width}x\{height}")
      true
    }
    _ => false
  }
}

// Component-level handlers
view.on_key(fn(key) {
  match key {
    Enter => { do_something(); true }
    _ => false
  }
})
.on_click(fn(x, y) {
  println("Clicked at \{x}, \{y}")
})
```

## Focus Management

The focus system automatically handles Tab navigation:

```moonbit
view
  .focusable()  // Make focusable
  .focused_border_color(@core.Color::Yellow)  // Highlight when focused
```

## Examples

Check out the `src/demo/` directory for complete examples:

- **`todo_app.mbt`** - Full-featured todo list with focus management
- **`counter.mbt`** - Simple counter with state management
- **`interactive.mbt`** - Mouse and keyboard interaction demo
- **`yoga_demo.mbt`** - Advanced flexbox layout examples
- **`box_demo.mbt`** - Border styles and overflow demonstration
- **`scroll_demo.mbt`** - Scrolling and viewport management

Run demos:

```bash
moon build --target native
./target/native/release/build/demo/demo.native
```

## Architecture

OneBit-TUI has a layered architecture:

```
┌──────────────────────────────────┐
│         Application Code          │
├──────────────────────────────────┤
│      Widgets (List, Input...)     │
├──────────────────────────────────┤
│    View System + Event Loop       │
├──────────────────────────────────┤
│      Yoga Layout Engine           │
├──────────────────────────────────┤
│    FFI Layer (Terminal I/O)       │
├──────────────────────────────────┤
│   Native Zig/C Renderer           │
└──────────────────────────────────┘
```

## Platform Support

- ✅ **macOS** (x64, ARM64) - Fully supported
- ✅ **Linux** (x64, ARM64) - Fully supported
- 🚧 **Windows** - Experimental (requires WSL for now)

## Building from Source

```bash
# Clone the repository
git clone https://github.com/Frank-III/onebit-tui
cd onebit-tui

# Build native library (one time)
./build_ffi.sh

# Build the project
moon build --target native

# Run demos
./target/native/release/build/demo/demo.native
```

## Dependencies

- **[onebit-yoga](https://github.com/Frank-III/onebit-yoga)** - Yoga layout engine bindings
- **Native renderer** - Bundled Zig/C renderer (built automatically)

## Current Limitations

- Windows support is experimental
- No support for background tasks/timers (coming soon)
- Limited to terminal capabilities (no images, etc.)

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

Areas where help is appreciated:

- Windows platform support
- Additional widgets
- Performance optimizations
- Documentation improvements

## License

MIT License - see LICENSE file for details

## Acknowledgments

OneBit-TUI is a MoonBit port of [OpenTUI](https://github.com/stonega/opentui), leveraging its high-performance Zig renderer while providing an idiomatic MoonBit API.

Special thanks to:

- The Yoga Layout team for the flexbox engine
- The OpenTUI team for the renderer foundation
- The MoonBit team for the language and tooling
