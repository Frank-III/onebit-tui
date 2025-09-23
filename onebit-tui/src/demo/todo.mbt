///|
/// Todo App - A real interactive TUI application using widgets
pub(all) struct TodoItem {
  mut text : String
  mut completed : Bool
}

///|
pub fn TodoItem::new(text : String) -> TodoItem {
  { text, completed: false }
}

///|
pub fn main_todo_app() -> Unit {
  println("Starting Todo App...")

  // Initialize app
  let app = match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(a) => a
  }

  // Application state
  let todos : Array[TodoItem] = [
    TodoItem::new("Build OneBit-TUI framework"),
    TodoItem::new("Implement Component trait"),
    TodoItem::new("Add Yoga layout support"),
    TodoItem::new("Create widget library"),
    TodoItem::new("Write documentation"),
  ]
  let selected_index = Ref::new(0)
  let input_mode = Ref::new(false) // false = list mode, true = input mode
  let new_todo_text = Ref::new("")
  let status_message = Ref::new(
    "Press 'a' to add, Space to toggle, 'd' to delete, 'q' to quit",
  )

  // Create focus manager
  let focus_manager = @widget.FocusManager::new()

  // Build UI function
  let build_ui = fn() -> @view.View {
    // Title
    let title = @widget.Text::heading("📝 Todo List App")
    let subtitle = @widget.Text::caption("Built with OneBit-TUI")

    // Stats
    let completed_count = filter_todos(todos, fn(t) { t.completed }).length()
    let total_count = todos.length()
    let stats = @widget.Text::body(
      "Completed: \{completed_count}/\{total_count} | Selected: \{selected_index.val}",
    )

    // Progress bar
    let progress = if total_count > 0 {
      completed_count.to_double() / total_count.to_double()
    } else {
      0.0
    }
    let progress_bar = @widget.ProgressBar::new(progress).with_style(
      @widget.ProgressStyle::simple(),
    )

    // Todo list
    let list = @widget.List::new(todos, fn(item : TodoItem, is_selected) {
        let checkbox = if item.completed { "[✓]" } else { "[ ]" }
        let text = if item.completed {
          // Strike-through effect with dim color
          "~\{item.text}~"
        } else {
          item.text
        }
        if is_selected {
          "→ \{checkbox} \{text}"
        } else {
          "  \{checkbox} \{text}"
        }
      })
      .visible_items(10)
      .selected(selected_index.val) // Set the current selection
      .on_select(fn(_item, index) { selected_index.val = index })

    // Note: List manages its own selection internally

    // Input field for new todos
    let input_field = if input_mode.val {
      @widget.TextInput::new(new_todo_text)
      .placeholder("Enter new todo...")
      .width(40.0)
    } else {
      @widget.TextInput::new(Ref::new(""))
      .placeholder("Press 'a' to add new todo")
      .width(40.0)
    }

    // Register focusable components
    focus_manager.clear()
    focus_manager.register("list", list)
    if input_mode.val {
      focus_manager.register("input", input_field)
    }

    // Status bar
    let status = @widget.Text::caption(status_message.val)

    // Build layout - cleaner without .render() calls!
    @view.View::container_views([
      // Header
      @view.View::container([title, subtitle])
      .direction(@view.Direction::Column)
      .align_items(@types.Align::Center)
      .padding(1.0),

      // Stats row
      @view.View::container([stats, progress_bar])
      .direction(@view.Direction::Row)
      .spacing(2.0)
      .padding(1.0),

      // Main content (flexible)
      @view.View::container([list, input_field])
      .direction(@view.Direction::Column)
      .spacing(1.0)
      .flex(1.0),

      // Status bar
      status.render(),
    ])
    .direction(@view.Direction::Column)
    .padding(2.0)
    .align_items(@types.Align::Stretch)
    .justify_content(@types.Justify::FlexStart)
  }

  // Run event loop
  @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
    match event {
      @ffi.InputEvent::Key(key) =>
        if input_mode.val {
          // Input mode
          match key {
            @ffi.KeyEvent::Enter =>
              // Add new todo
              if new_todo_text.val.length() > 0 {
                todos.push(TodoItem::new(new_todo_text.val))
                new_todo_text.val = ""
                input_mode.val = false
                status_message.val = "Todo added!"
                true
              } else {
                false
              }
            @ffi.KeyEvent::Escape => {
              // Cancel input
              new_todo_text.val = ""
              input_mode.val = false
              status_message.val = "Cancelled"
              true
            }
            @ffi.KeyEvent::Backspace =>
              // Delete character
              if new_todo_text.val.length() > 0 {
                let len = new_todo_text.val.length()
                let chars : Array[Char] = []
                for i = 0; i < len - 1; i = i + 1 {
                  match new_todo_text.val.get_char(i) {
                    Some(c) => chars.push(c)
                    None => ()
                  }
                }
                new_todo_text.val = String::from_array(chars)
                true
              } else {
                false
              }
            @ffi.KeyEvent::Char(c) => {
              // Add character
              new_todo_text.val = new_todo_text.val +
                c.to_char().unwrap_or(' ').to_string()
              true
            }
            _ => false
          }
        } else {
          // List mode
          match key {
            @ffi.KeyEvent::Char(97) => { // 'a'
              input_mode.val = true
              status_message.val = "Enter new todo and press Enter"
              true
            }
            @ffi.KeyEvent::Char(32) => // Space
              // Toggle completion
              if selected_index.val < todos.length() {
                todos[selected_index.val].completed = not(
                  todos[selected_index.val].completed,
                )
                status_message.val = "Toggled!"
                true
              } else {
                false
              }
            @ffi.KeyEvent::Char(100) => // 'd'
              // Delete todo
              if selected_index.val < todos.length() {
                remove_todo(todos, selected_index.val)
                if selected_index.val >= todos.length() &&
                  selected_index.val > 0 {
                  selected_index.val = selected_index.val - 1
                }
                status_message.val = "Deleted!"
                true
              } else {
                false
              }
            @ffi.KeyEvent::ArrowUp =>
              if selected_index.val > 0 {
                selected_index.val = selected_index.val - 1
                true
              } else {
                false
              }
            @ffi.KeyEvent::ArrowDown =>
              if selected_index.val < todos.length() - 1 {
                selected_index.val = selected_index.val + 1
                true
              } else {
                false
              }
            @ffi.KeyEvent::Char(113) => // 'q'
              // Quit - will be handled by event loop
              false
            _ => false
          }
        }
      _ => false
    }
  })

  // Cleanup
  app.cleanup()
  println("Todo App closed.")
}

// Helper to filter array

///|
fn filter_todos(
  todos : Array[TodoItem],
  predicate : (TodoItem) -> Bool,
) -> Array[TodoItem] {
  let result : Array[TodoItem] = []
  for i = 0; i < todos.length(); i = i + 1 {
    if predicate(todos[i]) {
      result.push(todos[i])
    }
  }
  result
}

// Helper to remove item from array

///|
fn remove_todo(todos : Array[TodoItem], index : Int) -> Unit {
  if index >= 0 && index < todos.length() {
    // Shift all elements after index
    for i = index; i < todos.length() - 1; i = i + 1 {
      todos[i] = todos[i + 1]
    }
    // Remove last element
    let _ = todos.pop()

  }
}
