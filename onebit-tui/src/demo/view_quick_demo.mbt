///| Minimal View + Yoga demo using App::render_view

fn quick_demo_main() -> Unit {
  println("=== OneBit-TUI View Demo ===")
  match @core.App::init() {
    None => println("Failed to initialize renderer")
    Some(app) => {
      // App state
      let selected : Ref[Int] = Ref::new(0)
      let items : Array[String] = [
        "First", "Second", "Third", "Fourth", "Fifth"
      ]
      let show_modal : Ref[Bool] = Ref::new(false)
      let dark_mode : Ref[Bool] = Ref::new(true)
      let notifications : Ref[Bool] = Ref::new(false)
      let theme : Ref[String] = Ref::new("dark")

      // Build a simple interactive UI tree
      let list_view = @components.vlist(items, selected)
        .focusable()
        .scrollable()
        .on_key(fn(key) {
          match key {
            @ffi.KeyEvent::ArrowUp => { if selected.val > 0 { selected.val = selected.val - 1 }; true }
            @ffi.KeyEvent::ArrowDown => { if selected.val < items.length() - 1 { selected.val = selected.val + 1 }; true }
            _ => false
          }
        })

      let name : Ref[String] = Ref::new("")
      let caret : Ref[Int] = Ref::new(0)

      let ui = @components.View::new()
        .column()
        .padding(1.0)
        .background(@core.Color::Black)
        .children([
          @components.View::new()
            .row()
            .justify_content(@types.Justify::SpaceBetween)
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("OneBit-TUI", Some(@core.Color::BrightWhite)),
              @components.View::text("Yoga Layout", Some(@core.Color::BrightCyan))
            ]),
          @components.View::new()
            .row()
            .flex(1.0)
            .padding(1.0)
            .children([
              @components.View::new()
                .column()
                .flex(1.0)
                .padding(1.0)
                .gap(1.0)
                .background(@core.Color::Gray)
                .children([
                  @components.View::text("Settings", Some(@core.Color::BrightYellow)),
                  @components.toggle("Dark Mode", dark_mode),
                  @components.checkbox("Enable Notifications", notifications),
                  @components.View::text("Theme:", Some(@core.Color::White)),
                  @components.radio_group(
                    [
                      @components.RadioOption::{ value: "light", label: "Light" },
                      @components.RadioOption::{ value: "dark", label: "Dark" },
                      @components.RadioOption::{ value: "auto", label: "Auto" }
                    ],
                    theme
                  )
                ]),
              @components.View::new()
                .column()
                .flex(2.0)
                .padding(1.0)
                .children([
                  @components.View::text("Main Content", Some(@core.Color::White)),
                  // Simple stats table
                  @components.simple_table(
                    ["Component", "Status", "Count"],
                    [
                      ["Checkboxes", "✓", "2"],
                      ["Radio Groups", "✓", "1"], 
                      ["Tables", "✓", "1"],
                      ["Modals", "✓", "0"]
                    ]
                  ),
                  @components.View::text("List Selection:", Some(@core.Color::BrightGreen)),
                  // Container with clipping flag enabled (no-op until upstream scissor available)
                  @components.View::new().clip_children(true).height(@types.Value::point(6.0)).children([ list_view ]),
                  // Editable input
                  @components.input_edit(name, caret=caret, placeholder="Type here...")
                ])
            ]),
          @components.View::new()
            .row()
            .padding(1.0)
            .gap(2.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Press 'q' to exit. Tab to change focus.", Some(@core.Color::BrightWhite)),
              @components.make_button("Show Modal", true, fn() { show_modal.val = true })
            ]),
          // Add modal if visible
          if show_modal.val {
            @components.alert_modal(
              "Welcome!",
              "This is a modal dialog with focus trap. Press Enter or click OK to close.",
              show_modal
            )
          } else {
            @components.View::new()
          }
        ])

      // Run interactive loop
      @components.run_event_loop(app, ui, fps=30)
      app.cleanup()
    }
  }
}
