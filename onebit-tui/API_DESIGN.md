# OneBit-TUI API Design

## Core Philosophy

- **Declarative**: Build UIs by describing what they should look like, not how to draw them
- **Composable**: Small, reusable components that combine into complex UIs
- **MoonBit-native**: Use MoonBit's strengths (traits, pattern matching, method chaining)
- **Yoga-powered**: Automatic layout calculation, no manual positioning

## Architecture Layers

```
┌─────────────────────────────────────┐
│         Application Code            │  <- User writes this
├─────────────────────────────────────┤
│          TUI API Layer              │  <- Declarative API (tui.mbt)
├─────────────────────────────────────┤
│        Layout Engine (Yoga)         │  <- Automatic positioning
├─────────────────────────────────────┤
│        Rendering Layer              │  <- Convert to terminal ops
├─────────────────────────────────────┤
│      FFI Layer (terminal_ffi)       │  <- Terminal I/O
└─────────────────────────────────────┘
```

## Proposed API Design

### 1. Application Initialization

```moonbit
// Simple initialization
let app = TUI::init()?

// With configuration
let app = TUI::init()
  .title("My App")
  .mouse(true)
  .fps(60)?
```

### 2. Declarative UI Building

```moonbit
// Using builder pattern with method chaining
let ui =
  box()
    .column()
    .padding(2.0)
    .gap(1.0)
    .children([
      text("Welcome to OneBit-TUI").color(Blue).bold(),

      box()
        .row()
        .gap(2.0)
        .children([
          button("OK").on_click(fn() { app.quit() }),
          button("Cancel").color(Red)
        ]),

      list(["Item 1", "Item 2", "Item 3"])
        .height(Pixels(10.0))
        .on_select(fn(index) { println("Selected: \{index}") })
    ])

app.set_ui(ui)
```

### 3. Component Types

```moonbit
// Basic components
text(content: String) -> Element
box() -> Element
button(label: String) -> Element
list(items: Array[String]) -> Element
input() -> Element
progress(value: Float) -> Element
table(data: TableData) -> Element

// Layout components
row(children: Array[Element]) -> Element
column(children: Array[Element]) -> Element
stack(children: Array[Element]) -> Element
scroll_view(child: Element) -> Element
split_pane(left: Element, right: Element) -> Element
```

### 4. Styling System

```moonbit
// Size units
enum Size {
  Auto               // Content-based
  Pixels(Float)      // Fixed pixels
  Percent(Float)     // Percentage of parent
  Fill               // flex: 1
}

// Fluent style API
element
  .width(Percent(50.0))
  .height(Fill)
  .padding(2.0)
  .margin(1.0)
  .background(Blue)
  .border(BorderStyle::Rounded)
  .shadow(true)
```

### 5. Layout Properties (via Yoga)

```moonbit
// Flexbox properties
.row()              // flex-direction: row
.column()           // flex-direction: column
.center()           // justify-content: center, align-items: center
.space_between()    // justify-content: space-between
.gap(2.0)          // gap between children
.flex(1.0)         // flex-grow: 1
```

### 6. Event Handling

```moonbit
// Events as methods
element
  .on_click(fn(x, y) { ... })
  .on_key(fn(key) { ... })
  .on_focus(fn() { ... })
  .on_blur(fn() { ... })
  .on_change(fn(value) { ... })
```

### 7. State Management

```moonbit
// Using Ref for mutable state
let counter = Ref::new(0)
let name = Ref::new("")

let ui = column([
  text("Count: \{counter.val}"),
  button("+").on_click(fn() { counter.val += 1 }),
  input().bind(name),
  text("Hello, \{name.val}")
])

// Re-render on state change
app.watch(counter, fn() { app.render() })
```

### 8. Main Loop

```moonbit
// Automatic rendering with state updates
app.run()

// Or manual control
app.run_with(fn(app) {
  // Custom update logic
  app.render()
})
```

## MoonBit-Specific Features

### 1. Trait-based Extensions

```moonbit
trait Styleable {
  style(Self) -> Style
  with_style(Self, (Style) -> Unit) -> Self
}

trait Layoutable {
  layout_node(Self) -> @wrapper.Node
  calculate_layout(Self) -> Unit
}

trait Renderable {
  render(Self, @ffi.Buffer, Int, Int) -> Unit
}
```

### 2. Pattern Matching for Events

```moonbit
match app.get_event() {
  Key('q') | Key('Q') => app.quit()
  Key('j') => list.move_down()
  Key('k') => list.move_up()
  Mouse(x, y, Left) => handle_click(x, y)
  Resize(w, h) => app.resize(w, h)
  _ => ()
}
```

### 3. Enum-based Configuration

```moonbit
enum Theme {
  Light
  Dark
  Custom(ThemeConfig)
}

enum BorderStyle {
  None
  Single
  Double
  Rounded
  Thick
}
```

### 4. Method Chaining with Self

```moonbit
pub fn Element::width(self : Element, size : Size) -> Element {
  self.style.width = size
  self  // Return self for chaining
}
```

## Comparison with TypeScript/React

### TypeScript/React OpenTUI:

```tsx
<box flexDirection="column" padding={2}>
  <text>Hello World</text>
  <button onClick={() => console.log("clicked")}>Click me</button>
</box>
```

### MoonBit OneBit-TUI:

```moonbit
box()
  .column()
  .padding(2.0)
  .children([
    text("Hello World"),
    button("Click me")
      .on_click(fn() { println("clicked") })
  ])
```

## Benefits of This Design

1. **No JSX needed** - Pure MoonBit code
2. **Type-safe** - Compiler catches errors
3. **Composable** - Build complex UIs from simple parts
4. **Efficient** - Yoga handles layout, minimal allocations
5. **Idiomatic** - Feels natural in MoonBit
6. **Testable** - UI is just data structures

## Implementation Priority

1. **Phase 1: Core** ✅
   - [x] TUI initialization
   - [x] Basic Element structure
   - [x] Yoga integration
   - [x] Rendering pipeline

2. **Phase 2: Components** (Next)
   - [ ] text, box, button
   - [ ] list, input
   - [ ] Basic styling

3. **Phase 3: Layout**
   - [ ] Flexbox properties
   - [ ] Sizing system
   - [ ] Spacing (padding/margin)

4. **Phase 4: Interaction**
   - [ ] Event handling
   - [ ] Focus management
   - [ ] State binding

5. **Phase 5: Advanced**
   - [ ] Animations
   - [ ] Themes
   - [ ] Custom components

## Example Application

```moonbit
fn main {
  let app = TUI::init()?
  let selected = Ref::new(0)
  let items = ["New", "Open", "Save", "Exit"]

  let ui =
    box()
      .column()
      .padding(1.0)
      .children([
        text("File Manager").bold().color(Blue),

        box()
          .border(Single)
          .title("Menu")
          .padding(1.0)
          .children([
            list(items)
              .bind_selection(selected)
              .on_select(fn(idx) {
                match items[idx] {
                  "Exit" => app.quit()
                  _ => println("Selected: \{items[idx]}")
                }
              })
          ]),

        text("Use ↑↓ to navigate, Enter to select, q to quit")
          .color(Gray)
      ])

  app.set_ui(ui)
  app.run()
}
```

## Questions to Consider

1. **Should we use traits or structs for components?**
   - Traits allow extension but are more complex
   - Structs are simpler but less flexible

2. **How to handle dynamic UIs?**
   - Rebuild entire tree on change?
   - Virtual DOM diffing?
   - Direct mutation?

3. **State management approach?**
   - Simple Ref-based (current plan)
   - Signal/reactive system
   - Redux-like store

4. **Component library structure?**
   - All in one module?
   - Separate modules per component?
   - Core + extensions?

## Next Steps

1. Implement basic components (text, box, button)
2. Test Yoga layout integration
3. Create working demo
4. Iterate based on usage
5. Add more components gradually
