///| Simple demo using the new App API

fn main {
  // Create and run a simple text app
  @core.App::new()
    .title("OneBit-TUI Demo")
    .size(80, 24)
    .background(@core.RGBA::new(0.1, 0.1, 0.2, 1.0))
    .on_update(fn(app, buffer) {
      // Draw some text
      buffer.draw_text("Welcome to OneBit-TUI!", 10, 5)
      buffer.draw_text("Press 'q' to quit", 10, 7)
      
      // Draw a simple box
      for x = 5; x < 40; x = x + 1 {
        buffer.draw_text("-", x.reinterpret_as_uint(), 10)
        buffer.draw_text("-", x.reinterpret_as_uint(), 15)
      }
      for y = 11; y < 15; y = y + 1 {
        buffer.draw_text("|", 5, y.reinterpret_as_uint())
        buffer.draw_text("|", 39, y.reinterpret_as_uint())
      }
      buffer.draw_text("Box Content", 20, 12)
    })
    .on_quit(fn() {
      println("Goodbye!")
    })
    .run()
}