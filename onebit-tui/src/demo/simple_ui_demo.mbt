///|
/// Simple UI Demo using the App struct
pub fn run_simple_ui_demo() -> Unit {
  println("Starting Simple UI Demo...")
  match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(app) => {
      // Run once with our UI
      app.run_once(fn(app) {
        // Draw header  
        app.draw_rect(0, 0, app.width, 3, @core.Color::Blue)
        app.draw_text("OneBit-TUI Simple Demo", 2, 1, @core.Color::BrightWhite)

        // Draw some boxes with text
        app.draw_rect(2, 4, 30, 8, @core.Color::Gray)
        app.draw_text("Box 1", 4, 5, @core.Color::White)
        app.draw_text("This is content", 4, 6, @core.Color::BrightCyan)
        app.draw_rect(35, 4, 30, 8, @core.Color::Gray)
        app.draw_text("Box 2", 37, 5, @core.Color::White)
        app.draw_text("More content here", 37, 6, @core.Color::BrightGreen)

        // Draw footer
        app.draw_rect(0, app.height - 3, app.width, 3, @core.Color::Blue)
        app.draw_text(
          "Simple UI without input handling",
          2,
          app.height - 2,
          @core.Color::BrightYellow,
        )
      })

      // Sleep so user can see
      @ffi.sleep_ms(3000)

      // Cleanup
      app.cleanup()
      println("Demo complete!")
    }
  }
}
