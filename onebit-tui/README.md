# 🌙 OneBit TUI

A modern, type-safe terminal UI framework for MoonBit featuring reactive state management and composable components.

## ✨ Features

- **Type-Safe Components**: TextInput, List, Table, Modal, Box with full MoonBit type safety
- **Reactive State Management**: Signal-based reactivity with computed values and effects
- **Efficient Rendering**: Cell-based buffer system for optimal terminal rendering
- **Rich Styling**: 24-bit color support, customizable borders, and flexible layouts
- **Zero Dependencies**: Pure MoonBit implementation

## 🚀 Quick Start

```moonbit
fn main {
  // Create a text input
  let mut input = @onebit-tui/components.TextInput::new(
    value="Hello, OneBit!",
    width=30,
    placeholder="Type here..."
  )

  // Create reactive state
  let counter = @onebit-tui/reactive.signal(0)
  let doubled = @onebit-tui/reactive.computed(fn() { counter.get() * 2 })

  // Render to buffer
  let buf = @onebit-tui/core.Buffer::new(80, 24)
  input.render(buf, 0, 0)
}
```

## 📦 Installation

Add OneBit TUI to your `moon.mod.json`:

```json
{
  "dependencies": {
    "onebit-tui": "github:yourusername/onebit-tui"
  }
}
```

## 🧩 Components

### TextInput

Interactive text input with cursor management:

```moonbit
let mut input = @components.TextInput::new(
  value="Initial text",
  width=40,
  placeholder="Enter text..."
)
```

### List

Scrollable list with selection:

```moonbit
let list = @components.List::new(
  items=[
    @components.ListItem::Text("Option 1"),
    @components.ListItem::Text("Option 2"),
    @components.ListItem::Separator,
    @components.ListItem::Text("Option 3")
  ],
  selected=0,
  style=@components.ListStyle::new(
    highlight_color=@core.Color::Yellow,
    selected_prefix="▶ ",
    unselected_prefix="  "
  )
)
```

### Table

Data tables with headers:

```moonbit
let mut table = @components.Table::new(
  headers=["Name", "Status", "Progress"],
  widths=[20, 10, 15]
)
table.add_row(["Task 1", "Active", "75%"])
```

### Modal

Popup dialogs:

```moonbit
let modal = @components.Modal::new(
  title="Confirm",
  content="Are you sure?",
  width=40,
  height=10,
  style=@components.ModalStyle::new(
    border_color=@core.Color::Red,
    title_color=@core.Color::White,
    content_color=@core.Color::White
  )
)
```

### Box

Container with borders:

```moonbit
let box = @components.Box::new(
  x=0, y=0,
  width=50, height=20,
  border=@components.Border::new(
    style=@components.BorderStyle::Rounded,
    color=@core.Color::Cyan
  ),
  title="My Box"
)
```

## ⚡ Reactive System

OneBit TUI includes a powerful reactive system:

```moonbit
// Create signals
let count = @reactive.signal(0)
let name = @reactive.signal("User")

// Create computed values
let greeting = @reactive.computed(fn() {
  "Hello, " + name.get() + "! Count: " + count.get().to_string()
})

// Create effects
@reactive.effect(fn() {
  println("Count changed to: " + count.get().to_string())
})

// Update values
count.set(count.get() + 1)
name.set("MoonBit Developer")
```

## 🎨 Styling

Rich color support with named colors and RGB:

```moonbit
// Named colors
@core.Color::Red
@core.Color::Green
@core.Color::Blue
@core.Color::Yellow
@core.Color::Magenta
@core.Color::Cyan

// RGB colors
@core.Color::Rgb(255, 128, 0)  // Orange
```

Border styles:

- `BorderStyle::Single`
- `BorderStyle::Double`
- `BorderStyle::Rounded`
- `BorderStyle::Bold`
- `BorderStyle::Ascii`

## 🏃 Examples

Check out the `src/examples/` directory for complete examples:

- `components_showcase.mbt` - Demonstrates all components
- `reactive_counter.mbt` - Interactive counter with reactive state
- `todo_list.mbt` - Complete TODO list application
- `basic_demo.mbt` - Simple demo with colors and animations

Run examples:

```bash
moon run src/examples --target native
```

## 🏗️ Architecture

OneBit TUI is organized into modules:

- **core**: Buffer system, colors, and basic types
- **components**: UI components (TextInput, List, Table, etc.)
- **reactive**: Signal-based reactivity system
- **ui**: Event loop and layout system (work in progress)
- **ffi**: Terminal FFI bindings (work in progress)

## 🚧 Current Status

### ✅ Working

- All core components (TextInput, List, Table, Modal, Box)
- Reactive state management
- Buffer rendering system
- Color and styling system

### 🔧 In Progress

- Event loop integration
- Terminal FFI for keyboard/mouse input
- Full interactivity

## 🤝 Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Built with [MoonBit](https://www.moonbitlang.com/) 🌙
