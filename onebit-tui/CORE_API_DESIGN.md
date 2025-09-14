# OneBit-TUI Core API Design

## Overview

This document outlines the core API architecture for OneBit-TUI, focusing on:

1. Event System
2. Rendering Pipeline
3. Layout Integration (Yoga)
4. Component Lifecycle
5. State Management

## 1. Core Event System

### Event Types (Algebraic Data Types)

```moonbit
// Core event type using algebraic data types
pub enum Event {
  // Input events
  Key(KeyEvent)
  Mouse(MouseEvent)
  Resize(width : Int, height : Int)

  // System events
  Init
  Shutdown
  Tick(timestamp : Double)

  // Custom events
  Custom(name : String, data : Json)
} derive(Show, Eq)

pub enum KeyEvent {
  Char(Char)
  Arrow(Direction)
  Function(Int)  // F1-F12
  Special(SpecialKey)
  WithModifiers(key : KeyEvent, ctrl : Bool, alt : Bool, shift : Bool, meta : Bool)
} derive(Show, Eq)

pub enum MouseEvent {
  Click(x : Int, y : Int, button : MouseButton)
  DoubleClick(x : Int, y : Int, button : MouseButton)
  Move(x : Int, y : Int)
  Scroll(x : Int, y : Int, delta : Int)
  Drag(start_x : Int, start_y : Int, end_x : Int, end_y : Int)
} derive(Show, Eq)

pub enum Direction {
  Up | Down | Left | Right
} derive(Show, Eq)

pub enum SpecialKey {
  Enter | Tab | Backspace | Delete | Escape
  Home | End | PageUp | PageDown
  Insert | Space
} derive(Show, Eq)

pub enum MouseButton {
  Left | Right | Middle | ScrollUp | ScrollDown
} derive(Show, Eq)
```

### Event Handler Pattern

```moonbit
// Event handler type
type EventHandler = (Event) -> EventResult

// Event result for propagation control
pub enum EventResult {
  Handled           // Stop propagation
  Propagate         // Continue to parent
  PreventDefault    // Prevent default behavior but propagate
} derive(Show, Eq)

// Event context for rich event handling
pub struct EventContext {
  event : Event
  timestamp : Double
  target : ComponentId?
  phase : EventPhase
  mut propagation_stopped : Bool
  mut default_prevented : Bool
}

pub enum EventPhase {
  Capture    // Top-down
  Target     // At target
  Bubble     // Bottom-up
} derive(Show, Eq)
```

## 2. Core Rendering Pipeline

### Render Tree Structure

```moonbit
// Core renderable trait replacement using algebraic types
pub enum Renderable {
  // Leaf nodes
  Text(content : String, style : TextStyle)
  Primitive(draw : DrawCommand)

  // Container nodes
  Container(children : Array[Renderable], layout : Layout)
  Transform(child : Renderable, transform : Transform)
  Clip(child : Renderable, bounds : Rect)

  // Special nodes
  Portal(child : Renderable, target : PortalTarget)
  Lazy(compute : () -> Renderable, cache : Ref[Renderable?])
  Empty
} derive(Show)

// Draw commands for primitives
pub enum DrawCommand {
  FillRect(rect : Rect, color : Color)
  DrawText(text : String, pos : Point, style : TextStyle)
  DrawLine(start : Point, end : Point, style : LineStyle)
  DrawBox(rect : Rect, border : BorderStyle)
  DrawImage(data : Bytes, rect : Rect)
  Custom(fn : (Buffer, Rect) -> Unit)
} derive(Show)

// Render context
pub struct RenderContext {
  buffer : Buffer
  bounds : Rect
  clip : Rect?
  transform : Transform
  theme : Theme
  debug : Bool
}

// Render function
pub fn render(
  renderable : Renderable,
  context : RenderContext
) -> RenderResult {
  match renderable {
    Text(content, style) => render_text(context, content, style)
    Container(children, layout) => render_container(context, children, layout)
    Transform(child, transform) => render_with_transform(context, child, transform)
    // ... handle all cases
  }
}
```

### Buffer Management

```moonbit
// Efficient buffer management
pub struct BufferManager {
  primary : Buffer
  secondary : Buffer
  mut current : BufferIndex
  dirty_regions : Array[Rect]
}

pub enum BufferIndex {
  Primary | Secondary
} derive(Show, Eq)

pub fn BufferManager::swap(self : BufferManager) -> Unit {
  self.current = match self.current {
    Primary => Secondary
    Secondary => Primary
  }
}

pub fn BufferManager::get_current(self : BufferManager) -> Buffer {
  match self.current {
    Primary => self.primary
    Secondary => self.secondary
  }
}

// Dirty region tracking for optimized rendering
pub fn BufferManager::mark_dirty(self : BufferManager, rect : Rect) -> Unit {
  self.dirty_regions.push(rect)
}

pub fn BufferManager::needs_redraw(self : BufferManager, rect : Rect) -> Bool {
  self.dirty_regions.iter().any(fn(dirty) { rect.intersects(dirty) })
}
```

## 3. Layout System Integration (Yoga)

### Layout Types

```moonbit
// Layout configuration
pub enum Layout {
  Flex(FlexLayout)
  Grid(GridLayout)
  Absolute(AbsoluteLayout)
  Yoga(YogaNode)  // Direct Yoga integration
  Custom(fn : (Rect, Array[Renderable]) -> Array[Rect])
} derive(Show)

pub struct FlexLayout {
  direction : FlexDirection
  justify : JustifyContent
  align : AlignItems
  gap : Int
  wrap : Bool
} derive(Show, Default)

pub enum FlexDirection {
  Row | Column | RowReverse | ColumnReverse
} derive(Show, Eq)

pub enum JustifyContent {
  Start | Center | End | SpaceBetween | SpaceAround | SpaceEvenly
} derive(Show, Eq)

pub enum AlignItems {
  Start | Center | End | Stretch | Baseline
} derive(Show, Eq)

// Layout calculation
pub fn calculate_layout(
  layout : Layout,
  container : Rect,
  children : Array[Renderable]
) -> Array[Rect] {
  match layout {
    Flex(config) => calculate_flex_layout(config, container, children)
    Grid(config) => calculate_grid_layout(config, container, children)
    Absolute(config) => calculate_absolute_layout(config, container, children)
    Yoga(node) => calculate_yoga_layout(node, container, children)
    Custom(fn) => fn(container, children)
  }
}

// Yoga integration
pub fn create_yoga_tree(renderable : Renderable) -> @yoga.Node {
  match renderable {
    Container(children, Yoga(node)) => {
      // Set up Yoga node
      for i = 0; i < children.length(); i = i + 1 {
        let child_node = create_yoga_tree(children[i])
        node.add_child(child_node)
      }
      node
    }
    _ => @yoga.Node::new()
  }
}
```

## 4. Component Lifecycle

### Component State Machine

```moonbit
// Component lifecycle states
pub enum LifecycleState {
  Created
  Mounting
  Mounted
  Updating
  Unmounting
  Unmounted
  Error(String)
} derive(Show, Eq)

// Component trait replacement using records
pub struct Component {
  id : ComponentId
  mut state : LifecycleState
  mut renderable : Renderable

  // Lifecycle hooks
  on_mount : Ref[(() -> Unit)?]
  on_update : Ref[((Component) -> Unit)?]
  on_unmount : Ref[(() -> Unit)?]
  on_error : Ref[((String) -> Unit)?]

  // Event handling
  event_handlers : Ref[Map[String, EventHandler]]

  // Children management
  mut children : Array[Component]
  mut parent : ComponentId?
}

// Lifecycle methods
pub fn Component::mount(self : Component) -> Result[Unit, ComponentError] {
  match self.state {
    Created => {
      self.state = Mounting

      // Call mount hook
      match self.on_mount.val {
        Some(hook) => hook()
        None => ()
      }

      self.state = Mounted
      Ok(())
    }
    _ => Err(ComponentError::InvalidState("Cannot mount from state: " + self.state.to_string()))
  }
}

pub fn Component::update(self : Component) -> Result[Unit, ComponentError] {
  match self.state {
    Mounted => {
      self.state = Updating

      // Call update hook
      match self.on_update.val {
        Some(hook) => hook(self)
        None => ()
      }

      self.state = Mounted
      Ok(())
    }
    _ => Err(ComponentError::InvalidState("Cannot update from state: " + self.state.to_string()))
  }
}
```

## 5. State Management Core

### Reactive State System

```moonbit
// Core state management
pub struct Store[State, Action] {
  mut state : State
  reducer : (State, Action) -> State
  subscribers : Ref[Array[(State) -> Unit]]
  middleware : Ref[Array[Middleware[State, Action]]]
}

type Middleware[State, Action] = (Store[State, Action], Action, (Action) -> Unit) -> Unit

pub fn Store::dispatch(self : Store[State, Action], action : Action) -> Unit {
  // Apply middleware
  let next = fn(action : Action) {
    let new_state = (self.reducer)(self.state, action)
    self.state = new_state

    // Notify subscribers
    let subs = self.subscribers.val
    for i = 0; i < subs.length(); i = i + 1 {
      subs[i](new_state)
    }
  }

  // Run through middleware chain
  if self.middleware.val.is_empty() {
    next(action)
  } else {
    run_middleware(self, action, next, 0)
  }
}

fn run_middleware[State, Action](
  store : Store[State, Action],
  action : Action,
  next : (Action) -> Unit,
  index : Int
) -> Unit {
  let middleware = store.middleware.val
  if index >= middleware.length() {
    next(action)
  } else {
    middleware[index](store, action, fn(action) {
      run_middleware(store, action, next, index + 1)
    })
  }
}

// Selector pattern for derived state
pub struct Selector[State, Selected] {
  select : (State) -> Selected
  mut cached : Selected?
  mut prev_state : State?
}

pub fn Selector::get(self : Selector[State, Selected], state : State) -> Selected {
  match self.prev_state {
    Some(prev) if equals(prev, state) => {
      match self.cached {
        Some(cached) => cached
        None => {
          let selected = (self.select)(state)
          self.cached = Some(selected)
          selected
        }
      }
    }
    _ => {
      let selected = (self.select)(state)
      self.prev_state = Some(state)
      self.cached = Some(selected)
      selected
    }
  }
}
```

## 6. Core Event Loop

### Main Application Loop

```moonbit
pub struct Application {
  store : Store[AppState, AppAction]
  renderer : Renderer
  event_queue : Queue[Event]
  components : Map[ComponentId, Component]
  root : ComponentId
  mut running : Bool
}

pub fn Application::run(self : Application) -> Result[Unit, AppError] {
  self.running = true

  // Initialize
  self.store.dispatch(AppAction::Init)

  // Main loop
  while self.running {
    // Process events
    while not(self.event_queue.is_empty()) {
      let event = self.event_queue.dequeue()?
      self.handle_event(event)?
    }

    // Update
    self.update()?

    // Render
    self.render()?

    // Sleep to control frame rate
    sleep_ms(16)  // ~60 FPS
  }

  // Cleanup
  self.store.dispatch(AppAction::Shutdown)
  Ok(())
}

fn Application::handle_event(self : Application, event : Event) -> Result[Unit, AppError] {
  match event {
    Key(Char('q')) if ctrl_pressed() => {
      self.running = false
      Ok(())
    }
    Resize(w, h) => {
      self.renderer.resize(w, h)
      self.store.dispatch(AppAction::Resize(w, h))
      Ok(())
    }
    _ => {
      // Route to focused component
      let focused = self.get_focused_component()
      match focused {
        Some(component) => component.handle_event(event)
        None => Ok(EventResult::Propagate)
      }
    }
  }
}
```

## 7. Integration Example

### Complete Example Using Core APIs

```moonbit
// Define app state
struct TodoState {
  items : Array[TodoItem]
  filter : TodoFilter
  input : String
}

enum TodoAction {
  Add(String)
  Toggle(Int)
  Remove(Int)
  SetFilter(TodoFilter)
  UpdateInput(String)
}

// Create app
fn create_todo_app() -> Application {
  // Define reducer
  let reducer = fn(state : TodoState, action : TodoAction) -> TodoState {
    match action {
      Add(text) => {
        let new_item = TodoItem::{ text, completed: false, id: generate_id() }
        { ..state, items: state.items.push(new_item), input: "" }
      }
      Toggle(id) => {
        let items = state.items.map(fn(item) {
          if item.id == id {
            { ..item, completed: not(item.completed) }
          } else {
            item
          }
        })
        { ..state, items }
      }
      SetFilter(filter) => { ..state, filter }
      UpdateInput(text) => { ..state, input: text }
      _ => state
    }
  }

  // Create store
  let store = Store::new(
    initial_state=TodoState::{
      items: [],
      filter: TodoFilter::All,
      input: ""
    },
    reducer=reducer
  )

  // Create root component
  let root = create_todo_component(store)

  // Create application
  Application::{
    store,
    renderer: Renderer::new(),
    event_queue: Queue::new(),
    components: Map::new(),
    root: root.id,
    running: false
  }
}

// Run the app
fn main() -> Unit {
  let app = create_todo_app()
  match app.run() {
    Ok(()) => println("App terminated successfully")
    Err(e) => println("App error: " + e.to_string())
  }
}
```

## Summary

This Core API design provides:

1. **Type-safe event system** with algebraic data types
2. **Efficient rendering pipeline** with dirty region tracking
3. **Flexible layout system** with Yoga integration
4. **Component lifecycle management** with state machines
5. **Predictable state management** with Redux-like patterns
6. **Composable architecture** using MoonBit's strengths

The design leverages MoonBit's:

- Algebraic data types for modeling domain
- Pattern matching for control flow
- First-class functions for flexibility
- Type safety for reliability
- Performance characteristics for efficiency
