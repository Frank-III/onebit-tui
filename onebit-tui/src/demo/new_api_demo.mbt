///| Demo of the new declarative API with Yoga layout

pub fn run_new_api_demo() -> Unit {
  println("Testing FFI layer...")
  
  // For now, always run the simple FFI demo to test if FFI works
  run_simple_ffi_demo()
}

// Simple FFI demo that we know works
fn run_simple_ffi_demo() -> Unit {
  let (width, height) = @ffi.get_terminal_size()
  
  match @ffi.Renderer::new(width, height) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      match @ffi.TerminalSession::new(raw_mode=true, mouse=true, resize_detection=false) {
        None => {
          println("Failed to create terminal session")
          renderer.destroy()
          return
        }
        Some(session) => {
          // Get buffer and draw
          let buffer = renderer.get_next_buffer()
          buffer.clear(0.0, 0.0, 0.0, 1.0)
          
          // Draw title
          buffer.draw_text("OneBit-TUI New API Demo", 5_U, 2_U, 
            fg_r=0.0, fg_g=1.0, fg_b=1.0)
          
          // Draw info
          buffer.draw_text("This will use Yoga layout soon!", 5_U, 4_U)
          buffer.draw_text("Terminal size: \{width}x\{height}", 5_U, 6_U)
          
          // Draw a box
          buffer.fill_rect(5_U, 8_U, 30_U, 5_U, 0.1, 0.1, 0.3, 1.0)
          buffer.draw_text("Press 'q' to quit", 7_U, 10_U, 
            fg_r=1.0, fg_g=1.0, fg_b=0.0)
          
          // Render
          renderer.render(force=true)
          
          // Simple event loop
          let mut running = true
          while running {
            match @ffi.poll_input_event() {
              @ffi.InputEvent::Key(key) => {
                match key {
                  @ffi.KeyEvent::Char(113) | @ffi.KeyEvent::Escape => {
                    running = false
                  }
                  _ => ()
                }
              }
              _ => @ffi.sleep_ms(10)
            }
          }
          
          // Cleanup
          session.cleanup()
          renderer.destroy()
          println("Demo finished!")
        }
      }
    }
  }
}