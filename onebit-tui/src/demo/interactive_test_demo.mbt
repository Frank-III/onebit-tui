///| Interactive test demo to verify input handling and state changes

fn main {
  println("=== OneBit-TUI Interactive Test Demo ===")
  println("This demo tests keyboard, mouse, focus, and state management")
  
  match @core.App::init() {
    None => println("Failed to initialize renderer")
    Some(app) => {
      // Test state variables
      let key_log : Ref[Array[String]] = Ref::new([])
      let mouse_log : Ref[Array[String]] = Ref::new([])
      let last_key : Ref[String] = Ref::new("None")
      let last_mouse : Ref[String] = Ref::new("No clicks yet")
      let focus_id : Ref[Int] = Ref::new(0)
      let click_count : Ref[Int] = Ref::new(0)
      
      // Interactive state
      let counter : Ref[Int] = Ref::new(0)
      let text_input : Ref[String] = Ref::new("")
      let text_caret : Ref[Int] = Ref::new(0)
      let checkbox_state : Ref[Bool] = Ref::new(false)
      let radio_value : Ref[String] = Ref::new("option1")
      let selected_item : Ref[Int] = Ref::new(0)
      
      // Add event to log (keep last 5 entries)
      let add_to_log = fn(log : Ref[Array[String]], entry : String) {
        log.val.push(entry)
        if log.val.length() > 5 {
          // Remove first item
          let new_log : Array[String] = []
          for i = 1; i < log.val.length(); i = i + 1 {
            new_log.push(log.val[i])
          }
          log.val = new_log
        }
      }
      
      // Build test UI
      let ui = @components.View::new()
        .column()
        .padding(1.0)
        .gap(1.0)
        .background(@core.Color::Black)
        .children([
          // Header
          @components.View::new()
            .row()
            .justify_content(@types.Justify::SpaceBetween)
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Interactive Test Demo", Some(@core.Color::BrightWhite)),
              @components.View::new().text_bind(fn() { "Focus ID: " + focus_id.val.to_string() }, color=@core.Color::Yellow)
            ]),
          
          // Main content area with three columns
          @components.View::new()
            .row()
            .flex(1.0)
            .gap(1.0)
            .children([
              // Left column - Input tests
              @components.View::new()
                .column()
                .flex(1.0)
                .padding(1.0)
                .gap(1.0)
                .border(@components.BorderStyle::Single, @core.Color::Gray)
                .children([
                  @components.View::text("Input Tests", Some(@core.Color::Yellow)),
                  
                  // Counter with buttons
                  @components.View::new()
                    .row()
                    .gap(1.0)
                    .children([
                      @components.make_button("-", false, fn() {
                        counter.val = counter.val - 1
                        add_to_log(mouse_log, "Clicked minus")
                      }),
                      @components.View::new()
                        .padding(1.0)
                        .border(@components.BorderStyle::Single, @core.Color::Cyan)
                        .children([
                          @components.View::new().text_bind(fn() { counter.val.to_string() }, color=@core.Color::BrightWhite)
                        ]),
                      @components.make_button("+", false, fn() {
                        counter.val = counter.val + 1
                        add_to_log(mouse_log, "Clicked plus")
                      })
                    ]),
                  
                  // Text input
                  @components.View::text("Text Input:", Some(@core.Color::White)),
                  @components.input_edit(text_input, caret=text_caret, placeholder="Type here...")
                    .on_key(fn(key) {
                      add_to_log(key_log, "Input key: " + key_to_string(key))
                      false  // Let input_edit handle it
                    }),
                  
                  // Checkbox
                  @components.checkbox("Test Checkbox", checkbox_state, on_change=fn(checked) {
                    add_to_log(mouse_log, "Checkbox: " + checked.to_string())
                  }),
                  
                  // Radio buttons
                  @components.View::text("Radio Group:", Some(@core.Color::White)),
                  @components.radio_group(
                    [
                      @components.RadioOption::{ value: "option1", label: "Option 1" },
                      @components.RadioOption::{ value: "option2", label: "Option 2" },
                      @components.RadioOption::{ value: "option3", label: "Option 3" }
                    ],
                    radio_value,
                    on_change=fn(value) {
                      add_to_log(mouse_log, "Radio: " + value)
                    }
                  )
                ]),
              
              // Middle column - Click areas
              @components.View::new()
                .column()
                .flex(1.0)
                .padding(1.0)
                .gap(1.0)
                .border(@components.BorderStyle::Single, @core.Color::Gray)
                .children([
                  @components.View::text("Mouse Test Areas", Some(@core.Color::Yellow)),
                  
                  // Click test areas
                  @components.View::new()
                    .padding(2.0)
                    .background(@core.Color::Red)
                    .focusable()
                    .on_click(fn(x, y) {
                      click_count.val = click_count.val + 1
                      last_mouse.val = "Red area @ (" + x.to_string() + "," + y.to_string() + ")"
                      add_to_log(mouse_log, "Clicked red area")
                    })
                    .on_key(fn(key) {
                      last_key.val = "Red: " + key_to_string(key)
                      add_to_log(key_log, "Red area key: " + key_to_string(key))
                      true
                    })
                    .children([
                      @components.View::text("Click me (Red)", Some(@core.Color::White)),
                      @components.View::new().text_bind(fn() { "Clicks: " + click_count.val.to_string() }, color=@core.Color::BrightWhite)
                    ]),
                  
                  @components.View::new()
                    .padding(2.0)
                    .background(@core.Color::Green)
                    .focusable()
                    .on_click(fn(x, y) {
                      last_mouse.val = "Green area @ (" + x.to_string() + "," + y.to_string() + ")"
                      add_to_log(mouse_log, "Clicked green area")
                    })
                    .on_key(fn(key) {
                      last_key.val = "Green: " + key_to_string(key)
                      add_to_log(key_log, "Green area key: " + key_to_string(key))
                      true
                    })
                    .children([
                      @components.View::text("Click me (Green)", Some(@core.Color::White))
                    ]),
                  
                  @components.View::new()
                    .padding(2.0)
                    .background(@core.Color::Blue)
                    .focusable()
                    .on_click(fn(x, y) {
                      last_mouse.val = "Blue area @ (" + x.to_string() + "," + y.to_string() + ")"
                      add_to_log(mouse_log, "Clicked blue area")
                    })
                    .on_key(fn(key) {
                      last_key.val = "Blue: " + key_to_string(key)
                      add_to_log(key_log, "Blue area key: " + key_to_string(key))
                      true
                    })
                    .children([
                      @components.View::text("Click me (Blue)", Some(@core.Color::White))
                    ]),
                  
                  // List with selection
                  @components.View::text("Selectable List:", Some(@core.Color::White)),
                  @components.vlist(
                    ["Item A", "Item B", "Item C", "Item D"],
                    selected_item
                  ).on_click(fn(x, y) {
                    add_to_log(mouse_log, "List click @ " + x.to_string() + "," + y.to_string())
                  })
                ]),
              
              // Right column - Event logs
              @components.View::new()
                .column()
                .flex(1.0)
                .padding(1.0)
                .gap(1.0)
                .border(@components.BorderStyle::Single, @core.Color::Gray)
                .children([
                  @components.View::text("Event Logs", Some(@core.Color::Yellow)),
                  
                  // Current state display
                  @components.View::new()
                    .column()
                    .gap(0.5)
                    .padding(1.0)
                    .background(@core.Color::Gray)
                    .children([
                      @components.View::text("Current State:", Some(@core.Color::BrightYellow)),
                      @components.View::new().text_bind(fn() { "Last Key: " + last_key.val }, color=@core.Color::White),
                      @components.View::new().text_bind(fn() { "Last Mouse: " + last_mouse.val }, color=@core.Color::White),
                      @components.View::new().text_bind(fn() { "Counter: " + counter.val.to_string() }, color=@core.Color::White),
                      @components.View::new().text_bind(fn() { "Input: \"" + text_input.val + "\"" }, color=@core.Color::White),
                      @components.View::new().text_bind(fn() { "Checkbox: " + checkbox_state.val.to_string() }, color=@core.Color::White),
                      @components.View::new().text_bind(fn() { "Radio: " + radio_value.val }, color=@core.Color::White),
                      @components.View::new().text_bind(fn() { "Selected: Item " + selected_item.val.to_string() }, color=@core.Color::White)
                    ]),
                  
                  // Key event log
                  @components.View::text("Key Events (last 5):", Some(@core.Color::Cyan)),
                  @components.View::new()
                    .column()
                    .padding(1.0)
                    .background(@core.Color::Black)
                    .children(build_log_views(key_log)),
                  
                  // Mouse event log
                  @components.View::text("Mouse Events (last 5):", Some(@core.Color::Cyan)),
                  @components.View::new()
                    .column()
                    .padding(1.0)
                    .background(@core.Color::Black)
                    .children(build_log_views(mouse_log))
                ])
            ]),
          
          // Footer with instructions
          @components.View::new()
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Tab: Focus | Space/Enter: Activate | Arrows: Navigate | Click: Mouse | q: Quit", Some(@core.Color::BrightWhite))
            ])
        ])
      
      // Run event loop with custom handler for global keys
      @components.run_event_loop(app, ui, focused_id=focus_id, fps=30)
      app.cleanup()
    }
  }
}

fn build_log_views(log : Ref[Array[String]]) -> Array[@components.View] {
  let views : Array[@components.View] = []
  for i = 0; i < log.val.length(); i = i + 1 {
    views.push(
      @components.View::text("• " + log.val[i], Some(@core.Color::Gray))
    )
  }
  if views.length() == 0 {
    views.push(@components.View::text("(no events yet)", Some(@core.Color::Gray)))
  }
  views
}

fn key_to_string(key : @ffi.KeyEvent) -> String {
  match key {
    @ffi.KeyEvent::Char(c) => "Char(" + c.to_string() + ")"
    @ffi.KeyEvent::Enter => "Enter"
    @ffi.KeyEvent::Backspace => "Backspace"
    @ffi.KeyEvent::Delete => "Delete"
    @ffi.KeyEvent::Tab => "Tab"
    @ffi.KeyEvent::Escape => "Escape"
    @ffi.KeyEvent::ArrowUp => "ArrowUp"
    @ffi.KeyEvent::ArrowDown => "ArrowDown"
    @ffi.KeyEvent::ArrowLeft => "ArrowLeft"
    @ffi.KeyEvent::ArrowRight => "ArrowRight"
    @ffi.KeyEvent::Home => "Home"
    @ffi.KeyEvent::End => "End"
    @ffi.KeyEvent::PageUp => "PageUp"
    @ffi.KeyEvent::PageDown => "PageDown"
    @ffi.KeyEvent::F(n) => "F" + n.to_string()
    _ => "Unknown"
  }
}