///| Minimal FFI test - standalone

fn main {
  println("Testing minimal FFI...")
  
  // Just test if we can create/destroy a renderer
  match @ffi.Renderer::new(80, 24) {
    Some(renderer) => {
      println("✓ Created renderer")
      renderer.destroy()
      println("✓ Destroyed renderer")
    }
    None => {
      println("✗ Failed to create renderer")
    }
  }
}