///| Modal demo (stub) – not implemented in MoonBit port yet
pub fn main_modal_demo() -> Unit {
  match @core.App::init() {
    None => println("Failed to initialize app")
    Some(app) => {
      let build_ui = fn() -> @view.View {
        @view.View::container_views([
          @view.View::text("Modal demo is not implemented yet", color=@core.Color::Yellow),
          @view.View::text("Press 'q' to quit", color=@core.Color::Gray),
        ])
        .direction(@view.Direction::Column)
        .padding(2.0)
      }
      @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
        match event {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false // q
          _ => false
        }
      })
      app.cleanup()
    }
  }
}
