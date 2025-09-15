///| Demo of the new declarative API with Yoga layout

pub fn main {
  // Initialize the TUI app
  match @core.TUI::init() {
    None => {
      println("Failed to initialize TUI")
      return
    }
    Some(app) => {
      // Build the UI declaratively
      let ui = build_ui()
      
      // Set the UI tree
      app.set_ui(ui)
      
      // Run the app
      app.run(fn(app) {
        // This is called every frame
        // We can update UI here if needed
      })
      
      // Cleanup
      app.cleanup()
      println("Goodbye!")
    }
  }
}

fn build_ui() -> @core.Element {
  // Create a simple layout with Yoga
  @core.box(
    title="OneBit-TUI Demo",
    border=true,
    children=[
      // Header
      @core.text("Welcome to OneBit-TUI!")
        .color(@core.BrightCyan)
        .padding(1.0),
      
      // Main content
      @core.text("This is a demo of the new declarative API")
        .color(@core.White),
        
      @core.text("It uses Yoga for automatic layout")
        .color(@core.Gray),
      
      // Footer
      @core.text("Press 'q' to quit")
        .color(@core.Gray)
        .padding(1.0)
    ]
  )
    .padding(1.0)
    .column()
    .width(@core.Fill)
    .height(@core.Fill)
}