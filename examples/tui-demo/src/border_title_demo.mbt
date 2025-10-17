///|
/// Border Title Alignment Demo
fn main_border_title_demo() -> Unit {
  match @core.App::init() {
    None => ()
    Some(app) => {
      fn build_ui() -> @view.View {
        let left = @view.View::container_views([
          @view.View::text("Left aligned title", color=@core.Color::White)
        ])
          .direction(@view.Direction::Column)
          .padding(1.0)
          .border(@view.BorderStyle::Single, color=@core.Color::Gray)
          .title("Left Title")
          .title_align(@view.TitleAlign::Left)
          .width(24.0)
          .height(6.0)

        let center = @view.View::container_views([
          @view.View::text("Center aligned title", color=@core.Color::White)
        ])
          .direction(@view.Direction::Column)
          .padding(1.0)
          .border(@view.BorderStyle::Double, color=@core.Color::Gray)
          .title("Centered Title")
          .title_align(@view.TitleAlign::Center)
          .width(28.0)
          .height(6.0)

        let right = @view.View::container_views([
          @view.View::text("Right aligned title", color=@core.Color::White)
        ])
          .direction(@view.Direction::Column)
          .padding(1.0)
          .border(@view.BorderStyle::Rounded, color=@core.Color::Gray)
          .title("Right Title")
          .title_align(@view.TitleAlign::Right)
          .width(24.0)
          .height(6.0)

        @view.View::container_views([
          @view.View::text("Border Title Alignment Demo", color=@core.Color::Cyan),
          @view.View::text("Left | Center | Right", color=@core.Color::Gray),
          @view.View::container_views([left, center, right])
            .direction(@view.Direction::Row)
            .spacing(2.0)
        ])
          .direction(@view.Direction::Column)
          .spacing(1.0)
          .padding(2.0)
      }

      @runtime.run_event_loop(app, build_ui, on_global_event=fn(ev) {
        match ev {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false // 'q'
          @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
          _ => true
        }
      })

      app.cleanup()
    }
  }
}

