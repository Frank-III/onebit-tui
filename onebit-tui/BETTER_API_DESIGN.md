# Better API Design for OneBit-TUI

## Current Problems

1. **Clunky Conversion**: Having to call `.as_renderable()` everywhere
2. **Manual Positioning**: Setting x, y, width, height manually
3. **Lack of Type Safety**: Using BaseRenderable loses component type info
4. **No Layout System**: No automatic layout like flexbox
5. **Verbose**: Too much boilerplate for simple UIs

## Ideal API (What We Want)

```moonbit
// Declarative, composable, type-safe
let ui = Box(
  title: "My App",
  border: .rounded,
  children: [
    VStack(spacing: 1, [
      Text("Welcome!", style: .bold),
      HStack([
        Button("OK") { println("OK clicked") },
        Button("Cancel") { println("Cancel clicked") }
      ])
    ])
  ]
)

// Or with builder pattern
let ui = Box::new()
  .title("My App")
  .border(.rounded)
  .child(
    VStack::new()
      .spacing(1)
      .children([
        Text::new("Welcome!").style(.bold),
        HStack::new().children([
          Button::new("OK").on_click(fn() { println("OK") }),
          Button::new("Cancel").on_click(fn() { println("Cancel") })
        ])
      ])
  )
```

## Design Principles

1. **Everything is a View**: Single trait that all components implement
2. **Automatic Layout**: Built-in layout system (flexbox-like)
3. **Type Safety**: Preserve component types through the hierarchy
4. **Declarative**: Describe what you want, not how to render it
5. **Composable**: Easy to combine components
6. **Minimal Boilerplate**: Sensible defaults, optional configuration

## Proposed Architecture

### 1. Core View Trait

```moonbit
trait View {
  // Core rendering
  render(Self, buffer: Buffer, bounds: Rect) -> Unit

  // Layout negotiation
  measure(Self, constraints: Constraints) -> Size

  // Event handling (optional)
  handle_event(Self, event: Event) -> Bool
}
```

### 2. Component Enum (for heterogeneous collections)

```moonbit
enum AnyView {
  Box(Box)
  Text(Text)
  Group(Group)
  VStack(VStack)
  HStack(HStack)
  // ... other components
}

impl View for AnyView {
  render(self, buffer, bounds) {
    match self {
      Box(b) => b.render(buffer, bounds)
      Text(t) => t.render(buffer, bounds)
      // ...
    }
  }
}
```

### 3. Smart Constructors

```moonbit
// Instead of Box::new("id"), just:
fn box(~title: String? = None, ~border: BorderStyle = .single) -> Box {
  { title, border, children: [], ... }
}

// Usage:
let ui = box(title: "Hello", border: .rounded)
```

### 4. Layout Containers

```moonbit
struct VStack {
  spacing: Int
  alignment: Alignment
  children: Array[AnyView]
}

struct HStack {
  spacing: Int
  alignment: Alignment
  children: Array[AnyView]
}

struct ZStack {
  children: Array[AnyView]
}
```

### 5. Builder Pattern (Optional)

```moonbit
impl Box {
  fn child(self, view: AnyView) -> Self {
    self.children.push(view)
    self
  }

  fn children(self, views: Array[AnyView]) -> Self {
    self.children = views
    self
  }
}
```

## Example Usage

```moonbit
fn main() {
  let ui = vstack(spacing: 2, [
    text("OneBit TUI Demo", style: .bold),

    hstack(spacing: 1, [
      box(title: "Status", [
        text("CPU: 42%"),
        text("Memory: 1.2GB")
      ]),

      box(title: "Logs", [
        text("System started"),
        text("Connection established")
      ])
    ]),

    text("Press 'q' to quit", style: .dim)
  ])

  // Render to terminal
  let terminal = Terminal::new()
  terminal.render(ui)
}
```

## Implementation Steps

1. Define View trait with render/measure methods
2. Create AnyView enum for polymorphic collections
3. Implement basic components (Box, Text, Group)
4. Add layout containers (VStack, HStack, ZStack)
5. Build constraint-based layout system
6. Add event handling
7. Create high-level Terminal API

## Benefits

- **Clean**: No more `.as_renderable()` calls
- **Type Safe**: Components maintain their types
- **Declarative**: Describe the UI structure naturally
- **Flexible**: Can use either functional or builder style
- **Extensible**: Easy to add new components
- **Performant**: Zero-cost abstractions where possible
