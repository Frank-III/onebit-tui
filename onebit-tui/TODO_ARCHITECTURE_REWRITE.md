# TODO: Complete Architecture Rewrite for onebit-tui

## Current Status

We have identified the correct architecture based on the TypeScript implementation:

- **BaseRenderable** is the foundation for ALL components
- ANY component can contain ANY other component as children
- Components are NOT hierarchical (Box is not special)

## Files Created So Far

1. `/onebit-tui/src/core/renderable.mbt` - BaseRenderable struct with:
   - id, bounds, visible, background_color, foreground_color
   - children array for ANY BaseRenderable
   - render_fn function pointer
   - Helper methods: add_child(), set_render_fn()

2. `/onebit-tui/PROPER_ARCHITECTURE.md` - Documentation of the correct approach

## What Needs to Be Done

### 1. Rewrite Box Component (HIGH PRIORITY)

- [ ] Update `/onebit-tui/src/components/box.mbt` to:
  ```moonbit
  struct Box {
    base: BaseRenderable
    border_style: BorderStyle
    border_color: RGBA
    title: String?
    title_align: TextAlign
    padding: Int
  }
  ```
- [ ] Implement Box::new() that creates BaseRenderable and sets render_fn
- [ ] Move render logic into a function that takes BaseRenderable
- [ ] Ensure Box can contain ANY component via base.children

### 2. Rewrite Text Component (HIGH PRIORITY)

- [ ] Update `/onebit-tui/src/components/text.mbt` to:
  ```moonbit
  struct Text {
    base: BaseRenderable
    content: String
    style: TextStyle
    wrap: Bool
    align: TextAlign
  }
  ```
- [ ] Implement proper render function
- [ ] Support text wrapping and alignment

### 3. Implement Group Component (HIGH PRIORITY)

- [ ] Create `/onebit-tui/src/components/group.mbt`
- [ ] Group is an invisible container (like React Fragment)
- [ ] Only renders its children, no visual representation

### 4. Create Helper Functions (MEDIUM PRIORITY)

- [ ] `vstack()` - Vertical stack layout
- [ ] `hstack()` - Horizontal stack layout
- [ ] `padding()` - Add padding around any component
- [ ] `center()` - Center any component
- [ ] `zstack()` - Z-axis stack (overlapping)

### 5. Create Demos (MEDIUM PRIORITY)

- [ ] Basic demo showing Text inside Box
- [ ] Demo showing Box inside Box inside Group
- [ ] Demo showing flexible composition with helpers
- [ ] Demo showing that ANY component can contain ANY component

### 6. Fix Existing Components (LOW PRIORITY)

- [ ] Update List component to use BaseRenderable
- [ ] Update Table component to use BaseRenderable
- [ ] Update Modal component to use BaseRenderable
- [ ] Update TextInput component to use BaseRenderable

## Key Architecture Points to Remember

1. **Every component has `base: BaseRenderable`**
2. **Components set their render function via `base.set_render_fn()`**
3. **ANY component can contain ANY other component via `base.children`**
4. **No special parent-child relationships - everything is a Renderable**
5. **Helper functions create and configure components, they don't wrap them**

## Example of Correct Usage

```moonbit
// Create components
let box = Box::new("outer-box")
let text = Text::new("hello-text", "Hello World")
let inner_box = Box::new("inner-box")

// Add children - ANY component can contain ANY component
box.base.add_child(text.base)
box.base.add_child(inner_box.base)

// Or use helpers
let ui = vstack([
  padding(10, text),
  center(inner_box)
])
```

## Testing Plan

1. Test that Box can contain Text
2. Test that Box can contain Box
3. Test that Text can contain Box (yes, even this!)
4. Test that Group properly renders children
5. Test helper functions create correct structures

## Migration Strategy

1. First implement new Box, Text, Group with BaseRenderable
2. Create demos to verify architecture works
3. Then migrate other components one by one
4. Update all examples to use new API

## Notes for Next Session

- Start with Box component rewrite
- Focus on getting the render function pointer pattern working
- Make sure to test child rendering early
- Don't worry about backwards compatibility - this is a full rewrite
