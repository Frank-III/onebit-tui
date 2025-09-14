# Current OneBit-TUI API Status

## What We Actually Have

### 1. BaseRenderable Architecture ✅

- All components use `BaseRenderable` as their core
- Components set their own `render_fn`
- Parent-child relationships work
- Z-index sorting

### 2. Component Inventory (19 components!)

- **Layout**: Box, FlexBox, Grid, Stack, Group, SplitPane
- **Input**: TextInput, Select, Toggle, TabSelect
- **Display**: Text, List, Table, Tree, ProgressBar
- **Feedback**: Modal, Tooltip, Spinner
- **Navigation**: TabView, ScrollView

### 3. FlexBox Component EXISTS!

We already have `src/components/flexbox.mbt` with:

- FlexDirection (Row, Column, etc.)
- FlexAlign (Start, Center, End, SpaceBetween, etc.)
- FlexWrap support
- Gap and padding
- Flex items with grow/shrink/basis

### 4. Yoga Integration

- `onebit-yoga` package with full Yoga bindings
- NodeBuilder with fluent API
- Layout calculation working

## The Problem: Two Layout Systems!

We have:

1. **FlexBox component** - Custom MoonBit implementation
2. **Yoga layout** - Facebook's flexbox engine

They're not integrated! Components don't know about Yoga.

## The Solution: Unified API

Instead of creating new components, we should:

### Option 1: Make Components Yoga-Aware

```moonbit
// Components automatically create Yoga nodes
let box = Box::new("mybox")
  .with_yoga()  // Enable Yoga layout
  .flex_grow(1.0)  // Sets on internal Yoga node
  .border_style(BorderStyle::Single)
```

### Option 2: Wrapper Components (like our ui.mbt)

```moonbit
// Thin wrappers that combine Yoga + Components
ui::box()
  .flex_grow(1.0)  // Yoga property
  .border(true)     // Component property
  .build()          // Creates Box + Yoga node
```

### Option 3: Use Existing FlexBox Component

```moonbit
// Our FlexBox already has the right API!
FlexBox::new(
  direction: Row,
  justify_content: SpaceBetween,
  gap: 2
)
.add_item(
  FlexItem::new(
    content: Box::new("sidebar"),
    flex_grow: 0.3  // 30% width
  )
)
```

## What's Actually Broken?

Looking at the build errors, the issues are:

1. **Method naming**: Components use different method names
2. **Type mismatches**: RGBA vs Color, etc.
3. **Missing imports**: Package references

## Recommended Approach

### Step 1: Fix the existing FlexBox component

- It already has the right flexbox API
- Just needs to integrate with Yoga for layout calculation
- Components can stay as they are

### Step 2: Create adapter layer

```moonbit
// Make FlexBox use Yoga internally
pub fn FlexBox::calculate_layout(self : FlexBox) -> Unit {
  // Convert FlexBox properties to Yoga
  let yoga_node = self.to_yoga_node()
  yoga_node.calculate_layout()

  // Apply calculated positions to items
  self.apply_yoga_layout(yoga_node)
}
```

### Step 3: Builder pattern for existing components

```moonbit
// Just add builder methods to existing components
impl Box {
  pub fn builder() -> BoxBuilder { ... }
}

impl List {
  pub fn builder() -> ListBuilder { ... }
}
```

## The Real Problem

We've been trying to redesign when we should be **integrating**:

1. ✅ We have components (19 of them!)
2. ✅ We have FlexBox with the right API
3. ✅ We have Yoga for layout calculation
4. ❌ They just don't talk to each other

## Next Steps

1. **Don't create new components** - we have plenty
2. **Connect FlexBox to Yoga** - for proper layout calculation
3. **Add builder pattern** - to existing components
4. **Fix the imports/types** - to get it compiling

The API is actually pretty good - it just needs the pieces connected!
