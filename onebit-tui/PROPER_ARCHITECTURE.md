# Proper Component Architecture for onebit-tui

## Key Insight

After studying the TypeScript implementation, I realized the fundamental architecture should be:

1. **Everything is a Renderable** - There's a base `Renderable` class/trait that ALL UI components extend from
2. **Any Renderable can contain any other Renderable** - The hierarchy is completely flexible
3. **Components are just specialized Renderables** - Box, Text, Group, Input, etc. are all just different types of Renderables

## Component Hierarchy

```
Renderable (base trait/class)
├── Box (draws borders and background)
├── Text (renders text)
├── Group (invisible container for layout)
├── Input (text input field)
├── Select (dropdown/list selection)
├── Table (data grid)
└── ... any other UI component
```

## Key Differences from Original Design

### OLD (Wrong) Approach:

- Box was the primary container
- Text was something you put "inside" a Box
- Limited flexibility in composition

### NEW (Correct) Approach:

- ALL components inherit from BaseRenderable
- ANY component can contain ANY other component
- Box is just ONE type of component (that happens to draw borders)
- Group is an invisible container for pure layout
- Much more flexible composition

## Example Usage

```moonbit
// Create a complex UI tree
let app = vstack("app", [
  // Box containing mixed components
  Box::new("header")
    .with_border(BorderStyle::Double)
    .add(
      hstack("header-content", [
        text("Logo"),                    // Text directly in the Box
        Group::new("spacer").with_flex(1.0),  // Invisible spacer
        Box::new("user-info")           // Box inside a Box!
          .add(text("User: admin"))
      ])
    ),

  // Group containing mixed components
  Group::new("body")
    .with_flex(1.0)
    .with_children([
      text("Welcome!"),                 // Text directly in a Group
      Box::new("content"),             // Box in a Group
      another_component                 // Any component works
    ]),

  // Text can even contain other components in theory!
  // (though typically it wouldn't)
])
```

## Benefits

1. **Maximum Flexibility** - Any component can contain any other
2. **Clean Separation** - Visual components (Box) vs layout components (Group) vs content (Text)
3. **Extensible** - Easy to add new component types
4. **Mirrors Modern UI Frameworks** - Similar to React, SwiftUI, etc.

## Implementation Details

### BaseRenderable

```moonbit
pub struct BaseRenderable {
  id : String
  x : Int
  y : Int
  width : Int
  height : Int
  visible : Bool
  children : Array[BaseRenderable]
  parent : BaseRenderable?
  z_index : Int
}
```

### Component Trait

```moonbit
pub trait Component {
  as_renderable(Self) -> BaseRenderable
  render(Self, buffer : TerminalBuffer) -> Unit
}
```

### Each Component Type

- Has a `base: BaseRenderable` field
- Implements the `Component` trait
- Adds its own specific properties and rendering logic
- Can contain ANY other component via the base children array

## This is the proper way to architect a UI framework!
