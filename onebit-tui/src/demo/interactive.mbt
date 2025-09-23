///|
/// Interactive Demo - Shows working keyboard and mouse input
fn main_interactive() -> Unit {
  // Initialize app
  let app = match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(a) => a
  }

  // State for the demo
  let counter = Ref::new(0)
  let last_key = Ref::new("Press any key")
  let mouse_pos = Ref::new((0, 0))
  let button_clicked = Ref::new(false)

  // Build UI function
  fn build_ui() -> @view.View {
    @view.View::container_views([
      // Title
      @view.View::text("Interactive OneBit-TUI Demo", color=@core.Color::Cyan).padding(
        2.0,
      ),

      // Instructions
      @view.View::text(
        "Use arrow keys, type characters, or click around",
        color=@core.Color::Gray,
      ).padding(1.0),

      // Counter display
      @view.View::container_views([
        @view.View::text(
          "Counter: " + counter.val.to_string(),
          color=@core.Color::Yellow,
        ),
        @view.View::text("↑/↓ to change", color=@core.Color::Gray),
      ])
      .direction(@view.Direction::Row)
      .spacing(2.0)
      .padding(2.0)
      .border(@view.BorderStyle::Single),

      // Last key pressed
      @view.View::text("Last key: " + last_key.val, color=@core.Color::Green).padding(
        2.0,
      ),

      // Mouse position
      @view.View::text(
        "Mouse: (" +
        mouse_pos.val.0.to_string() +
        ", " +
        mouse_pos.val.1.to_string() +
        ")",
        color=@core.Color::Magenta,
      ).padding(1.0),

      // Interactive button
      @view.View::text(
        if button_clicked.val {
          "Button: CLICKED!"
        } else {
          "Button: [ Click Me ]"
        },
        color=if button_clicked.val {
          @core.Color::BrightRed
        } else {
          @core.Color::White
        },
      )
      .padding(2.0)
      .background(
        if button_clicked.val {
          @core.Color::Red
        } else {
          @core.Color::Blue
        },
      )
      .border(@view.BorderStyle::Double),

      // Quit instruction
      @view.View::text("Press ESC or Ctrl+C to quit", color=@core.Color::Gray).padding(
        1.0,
      ),
    ])
    .direction(@view.Direction::Column)
    .spacing(1.0)
  }

  // Event handler
  fn handle_event(event : @ffi.InputEvent) -> Bool {
    match event {
      @ffi.InputEvent::Key(key) =>
        match key {
          @ffi.KeyEvent::ArrowUp => {
            counter.val = counter.val + 1
            last_key.val = "Up Arrow"
            true
          }
          @ffi.KeyEvent::ArrowDown => {
            counter.val = counter.val - 1
            last_key.val = "Down Arrow"
            true
          }
          @ffi.KeyEvent::ArrowLeft => {
            last_key.val = "Left Arrow"
            true
          }
          @ffi.KeyEvent::ArrowRight => {
            last_key.val = "Right Arrow"
            true
          }
          @ffi.KeyEvent::Char(c) => {
            last_key.val = "Char: " + c.to_string()
            true
          }
          @ffi.KeyEvent::Enter => {
            last_key.val = "Enter"
            button_clicked.val = not(button_clicked.val)
            true
          }
          @ffi.KeyEvent::Char(32) => {
            // Space character (ASCII 32)
            last_key.val = "Space"
            button_clicked.val = not(button_clicked.val)
            true
          }
          _ => {
            last_key.val = "Unknown key"
            true
          }
        }
      @ffi.InputEvent::MouseMove(x, y) => {
        mouse_pos.val = (x, y)
        true
      }
      @ffi.InputEvent::MouseDown(x, y, _button) => {
        mouse_pos.val = (x, y)
        // Simple hit test - if clicking in the button area
        if y > 10 && y < 14 {
          button_clicked.val = true
        }
        true
      }
      @ffi.InputEvent::MouseUp(_x, _y, _button) => {
        button_clicked.val = false
        true
      }
      _ => false
    }
  }

  // Run the event loop
  @runtime.run_event_loop(app, build_ui, on_global_event=handle_event)

  // Cleanup
  app.cleanup()
  println("\nInteractive demo finished!")
}
