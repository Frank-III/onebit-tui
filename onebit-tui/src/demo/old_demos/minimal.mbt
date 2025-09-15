///| Minimal demo - just render some text directly with FFI

fn main {
  // Create a renderer directly
  match @ffi.Renderer::new(80, 24) {
    Some(renderer) => {
      // Clear and get buffer
      renderer.clear_terminal()
      let buffer = renderer.get_next_buffer()
      
      // Draw some text
      buffer.draw_text("Hello from OneBit-TUI!", 10, 5)
      buffer.draw_text("This is a minimal MoonBit demo", 10, 7)
      buffer.draw_text("Press Ctrl+C to exit", 10, 9)
      
      // Render
      renderer.render()
      
      // Wait a bit (simple loop)
      for i = 0; i < 1000000000; i = i + 1 {
        // Just wait
      }
      
      // Clean up
      renderer.clear_terminal()
    }
    None => {
      println("Failed to create renderer")
    }
  }
}