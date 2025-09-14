///| Simple demo using the new App wrapper API
///| Shows how much cleaner the API is compared to raw terminal handling

fn main() -> Unit {
  // Create a simple counter app
  let mut counter = 0
  let mut status = "Press +/- to change counter"
  
  App::new()
    .title("Simple Counter App")
    .size(60, 20)
    .background(RGBA::new(0.1, 0.1, 0.2, 1.0))
    .fps(30)
    .on_key(Key::Plus, fn() {
      counter = counter + 1
      status = "Incremented!"
    })
    .on_key(Key::Minus, fn() {
      counter = counter - 1
      status = "Decremented!"
    })
    .on_key(Key::R, fn() {
      counter = 0
      status = "Reset!"
    })
    .on_update(fn(app, buffer) {
      // Draw title
      buffer.write_string(
        5, 2,
        "╔═══════════════════════════════════╗",
        RGBA::cyan(),
        RGBA::transparent(),
        TextStyle::None
      )
      buffer.write_string(
        5, 3,
        "║     Simple Counter Demo           ║",
        RGBA::cyan(),
        RGBA::transparent(),
        TextStyle::Bold
      )
      buffer.write_string(
        5, 4,
        "╚═══════════════════════════════════╝",
        RGBA::cyan(),
        RGBA::transparent(),
        TextStyle::None
      )
      
      // Draw counter
      buffer.write_string(
        5, 7,
        "Counter: \{counter}",
        RGBA::yellow(),
        RGBA::transparent(),
        TextStyle::Bold
      )
      
      // Draw status
      buffer.write_string(
        5, 9,
        "Status: \{status}",
        RGBA::green(),
        RGBA::transparent(),
        TextStyle::None
      )
      
      // Draw controls
      buffer.write_string(
        5, 12,
        "Controls:",
        RGBA::white(),
        RGBA::transparent(),
        TextStyle::Bold
      )
      buffer.write_string(
        5, 13,
        "  [+] Increment",
        RGBA::gray(),
        RGBA::transparent(),
        TextStyle::None
      )
      buffer.write_string(
        5, 14,
        "  [-] Decrement",
        RGBA::gray(),
        RGBA::transparent(),
        TextStyle::None
      )
      buffer.write_string(
        5, 15,
        "  [R] Reset",
        RGBA::gray(),
        RGBA::transparent(),
        TextStyle::None
      )
      buffer.write_string(
        5, 16,
        "  [Q/ESC] Quit",
        RGBA::gray(),
        RGBA::transparent(),
        TextStyle::None
      )
      
      // Draw frame counter
      buffer.write_string(
        5, 18,
        "Frame: \{app.get_frame_count()}",
        RGBA::gray(),
        RGBA::transparent(),
        TextStyle::None
      )
    })
    .run()
}