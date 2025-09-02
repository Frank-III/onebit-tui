///| Minimal FFI test

pub fn ffi_minimal_demo() -> Unit {
  println("=== Minimal FFI Demo ===")
  
  // Test creating a renderer
  match @core.Renderer::new(80, 24) {
    Some(renderer) => {
      println("✓ Successfully created FFI renderer")
      
      // Clear screen
      renderer.clear()
      println("✓ Cleared screen")
      
      // Draw some text
      renderer.draw_text(
        "Hello from OneBit-TUI FFI!",
        10, 5,
        color=@core.RGBA::green()
      )
      println("✓ Drew text")
      
      // Draw a filled rectangle
      renderer.fill_rect(
        10, 8, 60, 5,
        @core.RGBA::new(0.2, 0.2, 0.4, 1.0)
      )
      println("✓ Drew rectangle")
      
      // Present the frame
      renderer.present()
      println("✓ Presented frame")
      
      // Clean up
      renderer.destroy()
      println("✓ Destroyed renderer")
      
      println("\n✅ FFI integration is working!")
    }
    None => {
      println("❌ Failed to create renderer - FFI library may not be loaded")
    }
  }
}