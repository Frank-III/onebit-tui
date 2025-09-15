///|
/// Simple test to check if rendering works without terminal input
pub fn run_render_test() -> Unit {
  println("=== Render Test ===")
  let (width, height) = @ffi.get_terminal_size()
  println("Terminal size: \{width}x\{height}")
  match @ffi.Renderer::new(width, height) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      println("Renderer created successfully!")

      // Set background color
      renderer.set_background_color(0.1, 0.1, 0.2, 1.0)

      // Get buffer and draw
      let buffer = renderer.get_next_buffer()
      buffer.clear(0.05, 0.05, 0.1, 1.0)

      // Draw some text
      buffer.draw_text(
        "OneBit-TUI Render Test",
        5_U,
        2_U,
        fg_r=0.0,
        fg_g=1.0,
        fg_b=1.0,
      )
      buffer.draw_text(
        "Renderer: Working ✓",
        5_U,
        4_U,
        fg_r=0.0,
        fg_g=1.0,
        fg_b=0.0,
      )
      buffer.draw_text(
        "FFI Layer: Working ✓",
        5_U,
        5_U,
        fg_r=0.0,
        fg_g=1.0,
        fg_b=0.0,
      )

      // Draw a box
      buffer.fill_rect(5_U, 7_U, 30_U, 5_U, 0.2, 0.2, 0.4, 1.0)
      buffer.draw_text(
        "Box Drawing Works!",
        7_U,
        9_U,
        fg_r=1.0,
        fg_g=1.0,
        fg_b=0.0,
      )

      // Render the frame
      renderer.render(force=true)
      println("Frame rendered!")

      // Sleep a bit so user can see
      @ffi.sleep_ms(2000)

      // Cleanup
      renderer.destroy()
      println("Test complete!")
    }
  }
}
