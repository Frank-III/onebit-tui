///|
/// OneBit‑TUI Demo Launcher
fn main {
  println("OneBit-TUI Demo Launcher")
  println("========================")
  println("")
  println("Available demos:")
  println("1. TabSelect Demo - Horizontal tab selector")
  println("2. Select Demo - Dropdown selection widget")
  println("3. TextArea Demo - Text wrapping and scrolling")
  println("4. ScrollBox Demo - Scrollable list of items")
  println("5. Counter Demo - Simple state management")
  println("6. Modal Demo - Modal dialogs and confirmations")
  println("")
  println("Starting ScrollBox Demo...")
  println("")

  // Run a working demo
  main_tab_select_demo()
}

///|
pub fn run_tab_select() -> Unit {
  main_tab_select_demo()
}

///|
pub fn run_select() -> Unit {
  main_select_demo()
}

///|
pub fn run_dropdown_test() -> Unit {
  main_dropdown_test()
}

///|
pub fn run_text_area() -> Unit {
  main_text_area_demo()
}
