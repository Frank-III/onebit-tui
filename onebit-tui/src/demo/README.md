# OneBit-TUI Demo Applications

Clean, working demo applications showcasing the OneBit-TUI framework.

## Running Demos

```bash
# Run the launcher to see all demos
moon run src/demo/main.mbt

# Or run specific demos directly
moon run src/demo/todo.mbt        # Todo app
moon run src/demo/counter.mbt     # Counter app
moon run src/demo/interactive.mbt # Interactive demo
moon run src/demo/yoga.mbt        # Layout demo
```

## Available Demos

### 1. **Todo App** (`todo.mbt`)

Full-featured task management application with:

- ✅ Virtual scrolling list widget
- ✅ Text input for adding tasks
- ✅ Keyboard navigation (↑↓ arrows, Tab focus)
- ✅ Task completion toggling (Space key)
- ✅ Delete tasks ('d' key)
- ✅ Progress bar showing completion
- ✅ Focus visual indicators
- ✅ Responsive flexbox layout

**Controls:**

- `a` - Add new todo (enter input mode)
- `Space` - Toggle completion
- `d` - Delete selected todo
- `↑↓` - Navigate list
- `Tab` - Switch focus
- `q` - Quit

### 2. **Counter App** (`counter.mbt`)

Simple state management demonstration:

- Button widgets with actions
- Mutable state with `Ref[T]`
- Event callbacks
- Clean component composition

### 3. **Interactive Demo** (`interactive.mbt`)

Real-time input visualization:

- Keyboard event display
- Mouse position tracking
- Click coordinate logging
- Counter manipulation
- Live event feedback

### 4. **Yoga Layout Demo** (`yoga.mbt`)

Flexbox layout showcase:

- Row and column layouts
- Flex grow/shrink
- Alignment (center, stretch, flex-start)
- Spacing and padding
- Nested containers
- Responsive sizing

## Architecture

### Component System

```moonbit
// All widgets implement @view.Component trait
pub(open) trait Component {
  render(Self) -> View
  handle_event(Self, Event) -> Bool
  is_focusable(Self) -> Bool
}
```

### Clean API - No `.render()` calls needed!

```moonbit
// Before (verbose)
@view.View::container([
  title.render(),
  button.render(),
  input.render()
])

// After (clean)
@view.View::container([title, button, input])
```

### State Management

```moonbit
// Using Ref[T] for mutable state
let counter = Ref::new(0)
let text = Ref::new("Hello")

// Update state
counter.val = counter.val + 1
text.val = "Updated"
```

### Event Loop

```moonbit
@runtime.run_event_loop(
  app,
  build_ui,  // () -> View function
  on_global_event=fn(event) { ... }
)
```

## Key Features Demonstrated

1. **Widget-based UI** - Reusable components (Button, Text, TextInput, List, ProgressBar)
2. **Flexbox Layout** - Via Yoga integration for responsive design
3. **Event System** - Keyboard, mouse, focus, and resize events
4. **Focus Management** - Tab navigation with visual indicators
5. **Virtual Scrolling** - Efficient rendering of large lists
6. **Type Safety** - MoonBit's strong typing throughout

## Project Structure

```
demo/
├── README.md          # This file
├── main.mbt          # Demo launcher
├── todo.mbt          # Todo app
├── counter.mbt       # Counter demo
├── interactive.mbt   # Input demo
├── yoga.mbt          # Layout demo
└── moon.pkg.json     # Package config
```

## Notes

- All demos use the widget system from `/src/widget/`
- Components automatically implement `@view.Component` trait
- No need for explicit `.render()` calls when using `View::container`
- Focus indicators (cyan borders) work automatically for focusable widgets
- Terminal resize is handled automatically
