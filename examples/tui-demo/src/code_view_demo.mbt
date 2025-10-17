///|
/// CodeView demo - simple syntax highlighting for TS/JS-like code
fn main_code_view_demo() -> Unit {
  match @core.App::init() {
    None => ()
    Some(app) => {
      let sample = "import { createSignal } from 'solid-js'\n\nexport function Counter(initial: number) {\n  const [count, setCount] = createSignal(initial)\n  function inc() { setCount(count() + 1) }\n  return { inc }\n}\n"
      let text : Ref[String] = Ref::new(sample)
      let code = @widget.CodeView::new(text).size(64.0, 12.0)

      fn build_ui() -> @view.View {
        @view.View::container_views([
          @view.View::text("CodeView Demo", color=@core.Color::Cyan),
          code.render(),
        ])
        .direction(@view.Direction::Column)
        .spacing(1.0)
        .padding(2.0)
      }

      @runtime.run_event_loop(app, build_ui, on_global_event=fn(ev) {
        match ev {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false
          @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
          _ => false
        }
      })
      app.cleanup()
    }
  }
}
