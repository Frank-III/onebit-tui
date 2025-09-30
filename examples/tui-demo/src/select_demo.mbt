///|
/// Select demo (stub)
fn main_select_demo() -> Unit {
  match @core.App::init() {
    None => ()
    Some(app) => {
      let build_ui = fn() -> @view.View {
        @view.View::container_views([
          @view.View::text("Select demo is not implemented yet", color=@core.Color::Yellow),
        ])
        .direction(@view.Direction::Column)
        .padding(2.0)
      }
      @runtime.run_event_loop(app, build_ui, on_global_event=fn(_) { false })
      app.cleanup()
    }
  }
}
