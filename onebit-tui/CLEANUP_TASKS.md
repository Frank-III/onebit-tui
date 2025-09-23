# OneBit-TUI Cleanup Tasks

## Current Structure Analysis

### Components folder (15 files - TOO MANY!)

- `app.mbt` - Event loop (should be in app/ package)
- `checkbox.mbt` - Widget (should be in widgets/)
- `controls.mbt` - Mixed widgets (should be split)
- `dsl.mbt` - Builder helpers (unclear purpose)
- `event_loop.mbt` - Duplicate of app.mbt?
- `layout.mbt` - Yoga integration (should be in view/)
- `measurement.mbt` - Text measurement (should be in view/)
- `modal.mbt` - Widget (should be in widgets/)
- `render_helpers.mbt` - Rendering (should be in view/)
- `select.mbt` - Widget (should be in widgets/)
- `simple_loop.mbt` - Another event loop?
- `state.mbt` - State helpers (probably not needed)
- `table.mbt` - Widget (should be in widgets/)
- `view_events.mbt` - Event helpers (should be in events/)
- `view.mbt` - Core view type (should be in view/)

## Immediate Actions

### 1. Remove Duplicates

```bash
# Multiple event loops - keep only one
- event_loop.mbt
- simple_loop.mbt
- app.mbt (keep this, move to app/ package)

# State management - we use Refs
- state.mbt (remove - just use Ref)

# DSL/helpers - unclear purpose
- dsl.mbt (review and probably remove)
```

### 2. Create Clean Package Structure

```moonbit
// Core traits in onebit-tui/src/traits/component.mbt
trait Component {
  render(self : Self) -> View
  handle_key(self : Self, key : KeyEvent) -> Bool
  focusable(self : Self) -> Bool
}

// Simple widgets implementing the trait
// onebit-tui/src/widgets/button.mbt
pub struct Button {
  label : String
  action : () -> Unit
}

pub fn Button::new(label : String, action : () -> Unit) -> Button {
  { label, action }
}

impl Component for Button {
  fn render(self : Button) -> View {
    View::text(self.label)
      .padding(1.0)
      .border(BorderStyle::Single)
      .focusable(true)
  }

  fn handle_key(self : Button, key : KeyEvent) -> Bool {
    match key {
      Enter | Space => {
        self.action()
        true
      }
      _ => false
    }
  }

  fn focusable(self : Button) -> Bool { true }
}
```

### 3. View becomes Simple

```moonbit
// onebit-tui/src/view/view.mbt
pub struct View {
  // Layout
  mut width : Size?
  mut height : Size?
  mut flex : Double?
  mut direction : Direction?

  // Style
  mut background : Color?
  mut foreground : Color?
  mut border : Border?
  mut padding : Spacing?

  // Content
  content : ViewContent

  // Events (simple)
  mut on_key : (KeyEvent -> Bool)?
  mut on_click : ((Int, Int) -> Unit)?

  // Children
  children : Array[View]
}

enum ViewContent {
  Empty
  Text(String)
  Component(Component)  // Delegate to component
}
```

### 4. Single Event Loop

```moonbit
// onebit-tui/src/app/runner.mbt
pub fn run(
  app : App,
  root : () -> Component,  // Root component
  on_event? : (Event) -> Bool = fn(_) { true }
) -> Unit {
  while running {
    // Render
    let component = root()
    let view = component.render()
    render_view(app, view)

    // Handle events
    let event = poll_event()
    if not(component.handle_key(event)) {
      running = on_event(event)
    }
  }
}
```

## File Mapping

| Current File       | Action   | New Location                          |
| ------------------ | -------- | ------------------------------------- |
| app.mbt            | Move     | app/runner.mbt                        |
| checkbox.mbt       | Refactor | widgets/checkbox.mbt                  |
| controls.mbt       | Split    | widgets/button.mbt, widgets/radio.mbt |
| dsl.mbt            | Remove   | -                                     |
| event_loop.mbt     | Remove   | -                                     |
| layout.mbt         | Move     | view/layout.mbt                       |
| measurement.mbt    | Move     | view/measure.mbt                      |
| modal.mbt          | Refactor | widgets/modal.mbt                     |
| render_helpers.mbt | Move     | view/render.mbt                       |
| select.mbt         | Refactor | widgets/select.mbt                    |
| simple_loop.mbt    | Remove   | -                                     |
| state.mbt          | Remove   | -                                     |
| table.mbt          | Refactor | widgets/table.mbt                     |
| view_events.mbt    | Split    | events/helpers.mbt, widgets/\*        |
| view.mbt           | Move     | view/view.mbt                         |

## Benefits After Cleanup

1. **50% fewer files** - Remove duplicates and unnecessary code
2. **Clear organization** - Each package has single responsibility
3. **Trait-based** - All widgets implement Component
4. **Simple View** - Just data, no complex behavior
5. **One event system** - Not three different approaches
6. **MoonBit idiomatic** - Proper use of traits and modules

## Next Steps

1. Create the trait definition
2. Pick one widget (Button) and refactor as example
3. Test the new structure works
4. Gradually migrate other widgets
5. Remove old files once migrated

This will give us a MUCH cleaner, more maintainable codebase!
