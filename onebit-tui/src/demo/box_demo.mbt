///| Box and ScrollBox Demo - Testing new draw_box and scissor features

///|
pub fn main_box_demo() -> Unit {
  // Initialize app
  let app = @core.App::init()
  match app {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(app) => {
      // Create a demo with different box styles and title alignments
      fn build_ui() -> @view.View {
        @view.View::container_views([
          // Row with three boxes showing different title alignments
          @view.View::container_views([
            @view.View::text("Left Aligned Title", color=@core.Color::White)
            .width(25.0)
            .height(8.0)
            .padding(1.0)
            .border(@view.BorderStyle::Single, color=@core.Color::Cyan)
            .title("Left")
            .title_align(@view.TitleAlign::Left)
            .background(@core.rgb(20, 20, 40)),
            @view.View::text("Center Aligned Title", color=@core.Color::Yellow)
            .width(25.0)
            .height(8.0)
            .padding(1.0)
            .border(@view.BorderStyle::Double, color=@core.Color::Magenta)
            .title("Center")
            .title_align(@view.TitleAlign::Center)
            .background(@core.rgb(40, 20, 40)),
            @view.View::text("Right Aligned Title", color=@core.Color::Green)
            .width(25.0)
            .height(8.0)
            .padding(1.0)
            .border(@view.BorderStyle::Rounded, color=@core.Color::Green)
            .title("Right")
            .title_align(@view.TitleAlign::Right)
            .background(@core.rgb(20, 40, 20)),
          ])
          .direction(@view.Direction::Row)
          .spacing(2.0)
          .margin(1.0),

          // Box with overflow hidden to test scissoring
          @view.View::container_views([
            @view.View::text("Line 1: This text should be visible"),
            @view.View::text("Line 2: Also visible"),
            @view.View::text("Line 3: Still visible"),
            @view.View::text("Line 4: This might be cut off"),
            @view.View::text("Line 5: This should be hidden"),
            @view.View::text("Line 6: Definitely hidden"),
          ])
          .direction(@view.Direction::Column)
          .width(50.0)
          .height(5.0) // Only 5 lines high but has 6 lines of content
          .padding(1.0)
          .border(@view.BorderStyle::Single, color=@core.Color::Yellow)
          .title("Overflow Hidden Test")
          .title_align(@view.TitleAlign::Center)
          .overflow_y(@view.Overflow::Hidden)
          .margin(1.0),

          // Info box
          @view.View::text("Press 'q' or ESC to quit", color=@core.Color::Gray).margin(
            2.0,
          ),
        ]).direction(@view.Direction::Column)
      }

      // Run the event loop
      @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
        match event {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => true // 'q' to quit
          _ => false
        }
      })
      app.cleanup()
    }
  }
}
