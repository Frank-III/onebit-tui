///|
/// Simplified Component Demo - Start with something that compiles
pub fn run_simple_component_demo() -> Unit {
  println("Starting Simple Component Demo...")

  // Initialize renderer
  let (width, height) = @ffi.get_terminal_size()
  match @ffi.Renderer::new(width, height) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      // Get buffer for rendering
      let buffer = renderer.get_next_buffer()

      // Clear background
      buffer.clear(0.05, 0.05, 0.1, 1.0)

      // Draw a simple box manually for now
      draw_box(buffer, 5, 5, 40, 10, "Component Demo")

      // Draw some text inside
      buffer.draw_text(
        "Hello from Components!",
        7_U,
        7_U,
        fg_r=1.0,
        fg_g=1.0,
        fg_b=0.0,
      )
      buffer.draw_text("This is a test", 7_U, 9_U, fg_r=0.0, fg_g=1.0, fg_b=1.0)

      // Display
      renderer.render(force=true)

      // Wait for user to see
      @ffi.sleep_ms(3000)

      // Cleanup
      renderer.destroy()
      println("Simple component demo complete!")
    }
  }
}

///|
fn draw_box(
  buffer : @ffi.Buffer,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  title : String,
) -> Unit {
  // Simple ASCII box for now
  let x = x.reinterpret_as_uint()
  let y = y.reinterpret_as_uint()
  let w = w.reinterpret_as_uint()
  let h = h.reinterpret_as_uint()

  // Top line
  buffer.draw_text("+", x, y, fg_r=1.0, fg_g=1.0, fg_b=1.0)
  for i = 1_U; i < w - 1_U; i = i + 1_U {
    buffer.draw_text("-", x + i, y, fg_r=1.0, fg_g=1.0, fg_b=1.0)
  }
  buffer.draw_text("+", x + w - 1_U, y, fg_r=1.0, fg_g=1.0, fg_b=1.0)

  // Title
  if title.length() > 0 {
    buffer.draw_text(
      " " + title + " ",
      x + 2_U,
      y,
      fg_r=0.0,
      fg_g=1.0,
      fg_b=1.0,
    )
  }

  // Side lines
  for i = 1_U; i < h - 1_U; i = i + 1_U {
    buffer.draw_text("|", x, y + i, fg_r=1.0, fg_g=1.0, fg_b=1.0)
    buffer.draw_text("|", x + w - 1_U, y + i, fg_r=1.0, fg_g=1.0, fg_b=1.0)
  }

  // Bottom line
  buffer.draw_text("+", x, y + h - 1_U, fg_r=1.0, fg_g=1.0, fg_b=1.0)
  for i = 1_U; i < w - 1_U; i = i + 1_U {
    buffer.draw_text("-", x + i, y + h - 1_U, fg_r=1.0, fg_g=1.0, fg_b=1.0)
  }
  buffer.draw_text("+", x + w - 1_U, y + h - 1_U, fg_r=1.0, fg_g=1.0, fg_b=1.0)
}
