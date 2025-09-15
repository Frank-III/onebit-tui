// Real FFI demo - actually uses the terminal FFI
pub fn run_real_ffi_demo() -> Unit {
  // Get terminal size
  let (width, height) = @ffi.get_terminal_size()
  println("Terminal size: \{width}x\{height}")
  
  // Create a renderer
  match @ffi.Renderer::new(width, height) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      println("Renderer created successfully!")
      
      // Set background color (dark blue)
      renderer.set_background_color(0.1, 0.1, 0.3, 1.0)
      
      // Get a buffer for drawing
      let buffer = renderer.get_next_buffer()
      
      // Clear the buffer with a background color
      buffer.clear(0.0, 0.0, 0.0, 1.0)
      
      // Draw some text
      buffer.draw_text("Hello from OneBit-TUI!", 5_U, 5_U)
      buffer.draw_text("Built with MoonBit and FFI", 5_U, 7_U)
      buffer.draw_text("Terminal size: \{width}x\{height}", 5_U, 9_U)
      
      // Draw a box
      buffer.fill_rect(30_U, 5_U, 20_U, 5_U, 0.2, 0.5, 0.2, 1.0)
      buffer.draw_text("Box!", 35_U, 7_U, fg_r=1.0, fg_g=1.0, fg_b=0.0)
      
      // Set cursor position
      renderer.cursor(10, 15, visible=true)
      
      // Render the frame
      renderer.render(force=true)
      
      // Create terminal session for input
      match @ffi.TerminalSession::new(raw_mode=true, mouse=true, resize_detection=true) {
        None => {
          println("Failed to setup terminal session")
          renderer.destroy()
          return
        }
        Some(session) => {
          // Event loop
          let mut running = true
          while running {
            match @ffi.poll_input_event() {
              @ffi.InputEvent::Key(key) => {
                match key {
                  @ffi.KeyEvent::Char(113) => {  // 'q'
                    running = false
                  }
                  @ffi.KeyEvent::Escape => {
                    running = false
                  }
                  @ffi.KeyEvent::ArrowUp => {
                    buffer.clear(0.0, 0.0, 0.0, 1.0)
                    buffer.draw_text("You pressed UP!", 5_U, 5_U)
                    renderer.render()
                  }
                  @ffi.KeyEvent::ArrowDown => {
                    buffer.clear(0.0, 0.0, 0.0, 1.0)
                    buffer.draw_text("You pressed DOWN!", 5_U, 5_U)
                    renderer.render()
                  }
                  @ffi.KeyEvent::Char(c) => {
                    buffer.clear(0.0, 0.0, 0.0, 1.0)
                    buffer.draw_text("You pressed: \{c.unsafe_to_char()}", 5_U, 5_U)
                    buffer.draw_text("Press 'q' or ESC to quit", 5_U, 7_U)
                    renderer.render()
                  }
                  _ => ()
                }
              }
              @ffi.InputEvent::MouseDown(x, y, button) => {
                buffer.clear(0.0, 0.0, 0.0, 1.0)
                let button_name = match button {
                  @ffi.MouseButton::Left => "Left"
                  @ffi.MouseButton::Right => "Right"
                  @ffi.MouseButton::Middle => "Middle"
                  _ => "Unknown"
                }
                buffer.draw_text("Mouse \{button_name} click at (\{x}, \{y})", 5_U, 5_U)
                buffer.draw_text("Press 'q' or ESC to quit", 5_U, 7_U)
                renderer.render()
              }
              @ffi.InputEvent::Resize(new_width, new_height) => {
                renderer.resize(new_width, new_height)
                let new_buffer = renderer.get_next_buffer()
                new_buffer.clear(0.0, 0.0, 0.0, 1.0)
                new_buffer.draw_text("Terminal resized to \{new_width}x\{new_height}", 5_U, 5_U)
                new_buffer.draw_text("Press 'q' or ESC to quit", 5_U, 7_U)
                renderer.render()
              }
              _ => {
                // Small delay to avoid busy-waiting
                @ffi.sleep_ms(10)
              }
            }
          }
          
          // Cleanup
          session.cleanup()
          renderer.destroy()
          println("Goodbye!")
        }
      }
    }
  }
}