///| Main entry point for OneBit-TUI demos

fn main {
  println("=== OneBit-TUI Demos ===")
  println("1. Real FFI Demo")
  println("2. Showcase Demo")
  println("3. Terminal App Demo")
  println("4. New API Demo")
  println()
  println("Running New API Demo...")
  
  // Run the new API demo
  new_api_demo()
}

// Simple wrapper to call the new API demo
fn new_api_demo() -> Unit {
  @new_api_demo.main()
}