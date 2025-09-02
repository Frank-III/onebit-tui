///| Minimal FFI test

fn main {
  println("Testing OpenTUI FFI...")
  
  // Try to create a renderer
  match @ffi.Renderer::new(80.reinterpret_as_uint(), 24.reinterpret_as_uint()) {
    None => println("Failed to create renderer")
    Some(renderer) => {
      println("Success! Created renderer")
      
      // Set background
      renderer.set_background_color(0.1, 0.1, 0.2, 1.0)
      
      // Get buffer
      let buffer = renderer.get_next_buffer()
      println("Got buffer: \{buffer.width}x\{buffer.height}")
      
      // Clear
      buffer.clear(0.0, 0.0, 0.1, 1.0)
      
      // Draw some text
      buffer.draw_text(
        "Hello from OpenTUI FFI!",
        10.reinterpret_as_uint(),
        5.reinterpret_as_uint(),
        fg_r=1.0,
        fg_g=1.0,
        fg_b=1.0,
        bold=true
      )
      
      // Render
      renderer.render(force=true)
      
      // Cleanup
      renderer.destroy()
      
      println("FFI test complete!")
    }
  }
}