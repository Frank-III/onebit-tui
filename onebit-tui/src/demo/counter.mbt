///|
/// Counter App Demo - Tests reactivity, layout, and event handling
fn main_counter() -> Unit {
  // Initialize the app
  let app = match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(a) => a
  }

  // Shared state - multiple components will reference this
  let counter = Ref::new(0)
  let name = Ref::new("User")
  let show_details = Ref::new(false)

  // Create a simple event loop
  let frame = Ref::new(0)
  let running = Ref::new(true)
  while running.val && frame.val < 60 { // Run for 60 frames (about 1 second at 60fps)
    // Clear screen with dark blue background
    app.clear(0.05, 0.05, 0.1)

    // Build UI with current state
    let ui = build_ui(counter, name, show_details, frame.val)

    // TODO: Render the UI using Yoga layout
    // For now, just render some text to prove it works
    app.draw_text(
      "Counter Demo - Frame: " + frame.val.to_string(),
      10,
      2,
      @core.Color::BrightWhite,
    )
    app.draw_text(
      "Counter: " + counter.val.to_string(),
      10,
      4,
      @core.Color::Cyan,
    )
    app.draw_text("Name: " + name.val, 10, 6, @core.Color::Green)
    if show_details.val {
      app.draw_text("Details are visible!", 10, 8, @core.Color::Yellow)
    }

    // Simulate some events every few frames
    if frame.val % 10 == 0 {
      counter.val = counter.val + 1
    }
    if frame.val == 20 {
      name.val = "MoonBit User"
    }
    if frame.val == 30 {
      show_details.val = true
    }
    if frame.val == 45 {
      show_details.val = false
    }

    // Render frame
    app.render()

    // Simple sleep to control frame rate (about 16ms for 60fps)
    // TODO: Proper timing/input handling
    @ffi.sleep_ms(16)
    frame.val = frame.val + 1
  }

  // Cleanup
  app.cleanup()
  println("\nDemo completed - " + frame.val.to_string() + " frames rendered")
}

///|
/// Build the UI tree based on current state
fn build_ui(
  counter : Ref[Int],
  name : Ref[String],
  show_details : Ref[Bool],
  frame : Int,
) -> @view.View {
  // Create a column layout with multiple components
  @view.View::container_views([
    // Header
    @view.View::text("OneBit-TUI Demo", color=@core.Color::BrightWhite).padding(
      2.0,
    ),

    // Counter display - this will update when counter changes
    @view.View::text(
      "Count: " + counter.val.to_string(),
      color=@core.Color::Cyan,
    ).padding(1.0),

    // Name display - updates when name changes
    @view.View::text("Hello, " + name.val + "!", color=@core.Color::Green).padding(
      1.0,
    ),

    // Conditional rendering based on show_details
    if show_details.val {
      @view.View::container_views([
        @view.View::text("=== Details ===", color=@core.Color::Yellow),
        @view.View::text("Frame: " + frame.to_string()),
        @view.View::text("Counter * 2 = " + (counter.val * 2).to_string()),
      ])
      .direction(@view.Direction::Column)
      .spacing(1.0)
      .padding(2.0)
      .border(@view.BorderStyle::Single)
    } else {
      @view.View::empty()
    },

    // Footer
    @view.View::text("Press 'q' to quit", color=@core.Color::Gray).padding(1.0),
  ])
  .direction(@view.Direction::Column)
  .spacing(2.0)
  .padding(4.0)
}
