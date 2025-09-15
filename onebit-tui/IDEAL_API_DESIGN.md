# Ideal MoonBit TUI API Design

## Core Principles

1. **Type Safety**: Leverage MoonBit's strong type system
2. **Functional Style**: Immutable by default, explicit mutation
3. **Composable**: Small, focused components that combine well
4. **Zero-Cost Abstractions**: High-level API that compiles to efficient code
5. **Idiomatic**: Follow MoonBit patterns (traits, pattern matching, pipe operators)

## Architecture Layers

### 1. Foundation Layer (Low-Level FFI)

```moonbit
// Already implemented - our current FFI layer
pub struct Renderer { ... }
pub struct Buffer { ... }
```

### 2. Component Layer (Mid-Level)

```moonbit
// Base trait for all UI elements
pub trait Element {
  layout(self : Self, constraints : LayoutConstraints) -> LayoutResult
  render(self : Self, buffer : Buffer, bounds : Rect) -> Unit
  handle_event(self : Self, event : Event) -> EventResult
}

// Core components with builder pattern
pub struct Box {
  mut children : Array[Element]
  mut style : Style
  mut layout : LayoutStyle
}

pub fn Box::new() -> Box {
  Box::{
    children: [],
    style: Style::default(),
    layout: LayoutStyle::default()
  }
}

// Fluent API with pipe operator
pub fn Box::border(self : Box, style : BorderStyle) -> Box {
  self.style.border = Some(style)
  self
}

pub fn Box::padding(self : Box, padding : Spacing) -> Box {
  self.layout.padding = padding
  self
}

pub fn Box::child(self : Box, element : Element) -> Box {
  self.children.push(element)
  self
}
```

### 3. Declarative Layer (High-Level)

```moonbit
// DSL-like API using MoonBit's expression syntax
pub fn ui() -> Element {
  Box::new()
    |> _.border(BorderStyle::Rounded)
    |> _.padding(Spacing::all(2))
    |> _.child(
      Text::new("Hello, TUI!")
        |> _.color(Color::Cyan)
        |> _.bold()
    )
    |> _.child(
      Input::new()
        |> _.placeholder("Enter your name...")
        |> _.on_change(fn(value) {
          println("Input: \{value}")
        })
    )
}

// Alternative: Using builder functions
pub fn vbox(children : Array[Element]) -> Box
pub fn hbox(children : Array[Element]) -> Box
pub fn text(content : String) -> Text
pub fn input(props~ : InputProps = InputProps::default()) -> Input

// Usage:
let ui = vbox([
  text("Welcome") |> _.color(Color::Green),
  hbox([
    text("Name: "),
    input(placeholder="Enter name...")
  ]),
  button("Submit") |> _.on_click(handle_submit)
])
```

## Event System

```moonbit
pub enum Event {
  Key(KeyEvent)
  Mouse(MouseEvent)
  Resize(Int, Int)
  Custom(String, Json)
}

pub struct KeyEvent {
  key : Key
  modifiers : KeyModifiers
  raw : String?
}

pub enum Key {
  Char(Char)
  Enter
  Tab
  Backspace
  Delete
  Arrow(Direction)
  F(Int)  // F1-F12
  Escape
  // ...
}

pub struct KeyModifiers {
  ctrl : Bool
  alt : Bool
  shift : Bool
  meta : Bool
}

// Event handling with pattern matching
pub fn handle_event(event : Event) -> Unit {
  match event {
    Event::Key(KeyEvent::{ key: Key::Char('q'), modifiers: { ctrl: true, .. } }) =>
      quit_app()
    Event::Key(KeyEvent::{ key: Key::Enter, .. }) =>
      submit_form()
    Event::Mouse(MouseEvent::{ type: Click, x, y, .. }) =>
      handle_click(x, y)
    _ => ()
  }
}
```

## Layout System (with Yoga)

```moonbit
pub struct LayoutConstraints {
  min_width : Int?
  max_width : Int?
  min_height : Int?
  max_height : Int?
}

pub struct LayoutResult {
  width : Int
  height : Int
  x : Int
  y : Int
  children : Array[LayoutResult]
}

pub enum FlexDirection { Row | Column | RowReverse | ColumnReverse }
pub enum JustifyContent { Start | End | Center | SpaceBetween | SpaceAround | SpaceEvenly }
pub enum AlignItems { Start | End | Center | Stretch | Baseline }

pub struct LayoutStyle {
  direction : FlexDirection
  justify : JustifyContent
  align : AlignItems
  flex : Float?
  padding : Spacing
  margin : Spacing
  width : Size
  height : Size
}

pub enum Size {
  Auto
  Px(Int)
  Percent(Float)
  Fill
}
```

## State Management

```moonbit
// Signal-based reactive state (like SolidJS)
pub struct Signal[T] {
  mut value : T
  mut listeners : Array[(T) -> Unit]
}

pub fn Signal::new[T](initial : T) -> Signal[T]
pub fn Signal::get[T](self : Signal[T]) -> T
pub fn Signal::set[T](self : Signal[T], value : T) -> Unit
pub fn Signal::update[T](self : Signal[T], f : (T) -> T) -> Unit
pub fn Signal::subscribe[T](self : Signal[T], listener : (T) -> Unit) -> Unit

// Usage:
let counter = Signal::new(0)
let name = Signal::new("")

let ui = vbox([
  text(fn() { "Count: \{counter.get()}" }),
  button("+") |> _.on_click(fn() { counter.update(fn(n) { n + 1 }) }),
  input() |> _.bind(name),
  text(fn() { "Hello, \{name.get()}!" })
])
```

## Application Structure

```moonbit
pub struct Application {
  renderer : Renderer
  root : Element
  mut state : AppState
  mut running : Bool
  event_loop : EventLoop
}

pub fn Application::new(init : () -> Element) -> Application? {
  let (width, height) = get_terminal_size()
  match Renderer::new(width, height) {
    None => None
    Some(renderer) => {
      let root = init()
      Some(Application::{
        renderer,
        root,
        state: AppState::default(),
        running: true,
        event_loop: EventLoop::new()
      })
    }
  }
}

pub fn Application::run(self : Application) -> Unit {
  self.setup_terminal()

  while self.running {
    // Handle events
    self.event_loop.poll(fn(event) {
      self.root.handle_event(event)
    })

    // Layout
    let constraints = LayoutConstraints::{
      max_width: Some(self.renderer.width),
      max_height: Some(self.renderer.height),
      ..
    }
    let layout = self.root.layout(constraints)

    // Render
    let buffer = self.renderer.get_next_buffer()
    buffer.clear(0.0, 0.0, 0.0, 1.0)
    self.root.render(buffer, layout.to_rect())
    self.renderer.render()

    // Frame timing
    sleep_ms(16)  // ~60 FPS
  }

  self.cleanup()
}
```

## Component Examples

```moonbit
// List component
pub struct List {
  items : Array[String]
  selected : Int
  on_select : (Int, String) -> Unit
}

impl Element for List {
  fn render(self : List, buffer : Buffer, bounds : Rect) -> Unit {
    for i, item in self.items.iter().enumerate() {
      let y = bounds.y + i
      if i == self.selected {
        buffer.fill_rect(bounds.x, y, bounds.width, 1, BLUE)
        buffer.draw_text("> " + item, bounds.x, y, WHITE)
      } else {
        buffer.draw_text("  " + item, bounds.x, y, GRAY)
      }
    }
  }

  fn handle_event(self : List, event : Event) -> EventResult {
    match event {
      Event::Key(KeyEvent::{ key: Key::Arrow(Down), .. }) => {
        self.selected = (self.selected + 1) % self.items.length()
        EventResult::Consumed
      }
      Event::Key(KeyEvent::{ key: Key::Arrow(Up), .. }) => {
        self.selected = if self.selected == 0 {
          self.items.length() - 1
        } else {
          self.selected - 1
        }
        EventResult::Consumed
      }
      Event::Key(KeyEvent::{ key: Key::Enter, .. }) => {
        self.on_select(self.selected, self.items[self.selected])
        EventResult::Consumed
      }
      _ => EventResult::Ignored
    }
  }
}

// Modal/Dialog
pub fn dialog(title : String, message : String, buttons : Array[String]) -> Dialog {
  Dialog::{
    title,
    message,
    buttons: buttons.map(fn(label) { Button::new(label) }),
    selected: 0
  }
}

// Table with scrolling
pub struct Table[T] {
  columns : Array[Column[T]]
  rows : Array[T]
  scroll_offset : Int
  selected_row : Int?
  sort_by : String?
  sort_ascending : Bool
}

// Tabs
pub struct TabView {
  tabs : Array[(String, Element)]
  active_tab : Int
}
```

## Advanced Features

```moonbit
// Animations
pub struct Animation {
  duration : Int  // milliseconds
  easing : EasingFunction
  on_update : (Float) -> Unit  // progress 0.0 to 1.0
}

// Theming
pub struct Theme {
  colors : ColorScheme
  typography : Typography
  spacing : SpacingScale
  borders : BorderStyles
}

pub fn with_theme[T](theme : Theme, f : () -> T) -> T

// Focus Management
pub trait Focusable {
  focus(self : Self) -> Unit
  blur(self : Self) -> Unit
  is_focused(self : Self) -> Bool
}

// Keyboard shortcuts
pub struct Shortcut {
  key : Key
  modifiers : KeyModifiers
  action : () -> Unit
  description : String?
}

pub fn register_shortcuts(shortcuts : Array[Shortcut]) -> Unit

// Testing utilities
pub fn render_to_string(element : Element) -> String
pub fn simulate_key(element : Element, key : Key) -> Unit
pub fn simulate_click(element : Element, x : Int, y : Int) -> Unit
```

## Usage Example

```moonbit
fn main {
  let app = Application::new(fn() {
    let todos = Signal::new([])
    let input = Signal::new("")

    vbox([
      text("📝 Todo App") |> _.color(Color::Blue) |> _.bold(),

      hbox([
        input()
          |> _.placeholder("What needs to be done?")
          |> _.bind(input),
        button("Add")
          |> _.on_click(fn() {
            todos.update(fn(items) { items.push(input.get()) })
            input.set("")
          })
      ]) |> _.padding(Spacing::vertical(1)),

      List::new()
        |> _.items(todos)
        |> _.on_select(fn(idx, _) {
          todos.update(fn(items) { items.remove(idx) })
        })
        |> _.empty_message("No todos yet!")
    ])
    |> _.padding(Spacing::all(2))
    |> _.center()
  })

  match app {
    Some(app) => app.run()
    None => println("Failed to initialize TUI")
  }
}
```

## Key Advantages of This Design

1. **Type Safety**: All components strongly typed, compile-time guarantees
2. **Functional Reactive**: Signal-based state management, immutable by default
3. **Composable**: Small components combine into complex UIs
4. **Performance**: Zero-cost abstractions, direct buffer manipulation when needed
5. **Ergonomic**: Fluent API with pipe operators, pattern matching for events
6. **Testing**: Pure functions, testable components
7. **Familiar**: Similar to React/SolidJS but adapted for MoonBit idioms

## Implementation Priority

1. ✅ FFI Layer (done)
2. ⚠️ Event System (partial - keyboard input works)
3. 🔄 Basic Components (Box, Text - in progress)
4. ⬜ Layout System (Yoga integration)
5. ⬜ State Management (Signals)
6. ⬜ Component Library
7. ⬜ Themes & Styling
8. ⬜ Advanced Features

This design provides a modern, ergonomic TUI library that feels natural in MoonBit while achieving feature parity with the TypeScript implementation.
