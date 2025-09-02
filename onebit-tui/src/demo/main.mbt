///| Main entry point - runs demos
///| Provides a menu to select different demos

fn main {
  // Check command line arguments or show menu
  println("=== OneBit-TUI Demo Selector ===")
  println("1. Interact View Demo (Yoga + events)")
  println("2. Yoga Layout Demo (Box/VStack/HStack)")
  println("3. Event Loop Demo (Buttons)")
  println("4. Mouse & Resize Demo")
  println("5. Dashboard Demo")
  println("6. File Explorer Demo (Mock)")
  println("7. Real File Explorer (with fs)")
  println("8. Select Component Demo")
  println("")
  println("Running Select Component Demo...")
  
  // For now, run Select demo to test the new component
  run_select_demo()
}
