///|
/// TextInput demo - caret, word navigation, and paste
fn main_input_demo() -> Unit {
  match @core.App::init() {
    None => ()
    Some(app) => {
      let text = Ref::new("")
      let input = @widget.TextInput::new(text)
        .placeholder("Type here (Ctrl+W/A/E, Alt/Ctrl+←/→)")
        .width(40.0)
      let status = Ref::new("Keys: (none)".to_string())

      fn build_ui() -> @view.View {
        @view.View::container_views([
          @view.View::text("TextInput Demo", color=@core.Color::Cyan),
          @view.View::text("Caret visible when focused; Ctrl/Alt+Left/Right = word nav; Ctrl+W/U/K = word/start/end delete; paste supported.", color=@core.Color::Gray),
          input.render(),
          @view.View::text("Value: \{text.val}", color=@core.Color::Yellow),
          @view.View::text(status.val, color=@core.Color::Gray),
        ])
        .direction(@view.Direction::Column)
        .spacing(1.0)
        .padding(2.0)
      }

      @runtime.run_event_loop(app, build_ui, on_global_event=fn(ev) {
        match ev {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false // 'q'
          @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
          @ffi.InputEvent::Key(key) => {
            let pk = @events.parse_key_event_simple(key)
            status.val = "Keys: ".to_string() + pk.name
            false
          }
          @ffi.InputEvent::KeyMod(key, mods) => {
            let pk = @events.parse_key_event(key, mods)
            let mods_label = (if pk.ctrl { "Ctrl+" } else { "" }) + (if pk.alt { "Alt+" } else { "" }) + (if pk.shift { "Shift+" } else { "" }) + (if pk.meta { "Meta+" } else { "" })
            status.val = "Keys: ".to_string() + mods_label + pk.name
            false
          }
          _ => false
        }
      })

      app.cleanup()
    }
  }
}
