///|
/// Main demo launcher - run different examples
fn main {
  println("OneBit-TUI Demo Launcher")
  println("========================")
  println("")
  println("Available demos:")
  println("1. Todo App - Full-featured task manager")
  println("2. Counter App - Simple state management")
  println("3. Interactive Demo - Mouse and keyboard interactions")
  println("4. Yoga Layout Demo - Flexbox layout examples")
  println("5. Box Demo - Native draw_box with title alignment and overflow")
  println("")
  println("Run with: moon run src/demo/<demo_name>.mbt")
  println("")
  println("Starting Box Demo for testing...")
  println("")

  // Run the box demo for testing native draw_box
  main_box_demo()
}

// Re-export demo functions for individual running

///|
pub fn run_todo() -> Unit {
  main_todo_app()
}

///|
pub fn run_counter() -> Unit {
  main_counter()
}

///|
pub fn run_interactive() -> Unit {
  main_interactive()
}

///|
pub fn run_yoga_demo() -> Unit {
  test_yoga_layout()
}

///|
pub fn run_box_demo() -> Unit {
  main_box_demo()
}
