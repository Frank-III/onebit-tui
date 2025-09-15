///|
/// DSL Demo - Shows the clean, declarative API
pub fn run_dsl_demo() -> Unit {
  println("=== DSL Demo - Clean API ===")
  match @core.App::init() {
    None => println("Failed to initialize app")
    Some(app) => {
      app.run_once(fn(app) {
        // Build UI using DSL - much cleaner!
        let ui = @components.header_body_footer(
          // Header
          @components.center(
            @components.text("Task Manager", Some(@core.Color::BrightCyan)),
          ).background(@core.Color::DarkBlue),

          // Body with sidebar
          @components.sidebar_layout(
            // Sidebar
            @components.vbox([
              @components.text("Menu", Some(@core.Color::BrightWhite)),
              @components.divider(true),
              @components.list(["Dashboard", "Tasks", "Settings", "Help"]),
            ])
            .padding(1.0)
            .background(@core.Color::DarkGray),

            // Main content
            @components.vbox([
              @components.card(
                "Today's Tasks",
                @components.list([
                  "Fix component system", "Implement Yoga layout", "Create demos",
                  "Write documentation",
                ]),
              ),
              @components.spacer(),
              @components.card(
                "Quick Actions",
                @components.hbox([
                  @components.button("Add Task", true),
                  @components.spacer(),
                  @components.button("Refresh", false),
                  @components.spacer(),
                  @components.button("Export", false),
                ]),
              ),
            ]).padding(2.0),
          ),

          // Footer
          @components.hbox([
            @components.text("Ready", Some(@core.Color::Green)),
            @components.spacer(),
            @components.text("Press 'q' to quit", Some(@core.Color::Gray)),
          ])
          .padding(1.0)
          .background(@core.Color::DarkGray),
        )

        // Calculate and render
        ui.calculate_layout(app.width.to_double(), app.height.to_double())
        ui.render(app, 0, 0)
      })
      @ffi.sleep_ms(10000)
      app.cleanup()
      println("Demo complete!")
    }
  }
}

// Example of building a form with DSL

///|
pub fn create_form() -> @components.View {
  @components.vbox([
    @components.text("User Registration", Some(@core.Color::BrightWhite)),
    @components.divider(true),

    // Form fields
    @components.vbox([
      @components.text("Username:", Some(@core.Color::Gray)),
      @components.input_field("Enter username...", ""),
      @components.text("Email:", Some(@core.Color::Gray)),
      @components.input_field("Enter email...", ""),
      @components.text("Password:", Some(@core.Color::Gray)),
      @components.input_field("Enter password...", ""),
    ]).padding(1.0),

    // Actions
    @components.hbox([
      @components.button("Submit", true),
      @components.spacer(),
      @components.button("Cancel", false),
    ]).padding(1.0),
  ])
  .padding(2.0)
  .border(@components.BorderStyle::Rounded, @core.Color::Blue)
}

// Example of a dashboard layout

///|
pub fn create_dashboard() -> @components.View {
  @components.grid(2, [
    @components.card(
      "CPU Usage",
      @components.text("45%", Some(@core.Color::Green)),
    ),
    @components.card(
      "Memory",
      @components.text("2.3 GB", Some(@core.Color::Yellow)),
    ),
    @components.card(
      "Disk",
      @components.text("120 GB free", Some(@core.Color::Cyan)),
    ),
    @components.card(
      "Network",
      @components.text("1.2 MB/s", Some(@core.Color::Magenta)),
    ),
  ])
}
