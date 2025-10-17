///|
/// Select demo - interactive dropdown with keyboard
fn main_select_demo() -> Unit {
  match @core.App::init() {
    None => ()
    Some(app) => {
      let options = ["Apple", "Banana", "Cherry", "Durian", "Elderberry", "Fig", "Grape"]
      let selected : Ref[Int?] = Ref::new(None)

      let select = @widget.Select::new(options, fn(s) { s }, selected=selected)
        .with_id(3001)
      let status_key = Ref::new("Keys: (none)".to_string())

      fn build_ui() -> @view.View {
        let status = match selected.val {
          Some(i) => "Selected: \{options[i]} (\{i})"
          None => "Selected: <none>"
        }
        @view.View::container_views([
          @view.View::text("Select Widget Demo", color=@core.Color::Cyan),
          @view.View::text("Arrows to navigate, Enter/Space to toggle/select, Esc to close, Tab to move focus", color=@core.Color::Gray),
          select.render(),
          @view.View::text(status, color=@core.Color::Yellow),
          @view.View::text(status_key.val, color=@core.Color::Gray),
        ])
        .direction(@view.Direction::Column)
        .spacing(1.0)
        .padding(2.0)
      }

      @runtime.run_event_loop(app, build_ui, on_global_event=fn(ev) {
        match ev {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false // 'q' to quit
          @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
          @ffi.InputEvent::Key(key) => {
            let pk = @events.parse_key_event_simple(key)
            status_key.val = "Keys: ".to_string() + pk.name
            false
          }
          @ffi.InputEvent::KeyMod(key, mods) => {
            let pk = @events.parse_key_event(key, mods)
            let mods_label = (if pk.ctrl { "Ctrl+" } else { "" }) + (if pk.alt { "Alt+" } else { "" }) + (if pk.shift { "Shift+" } else { "" }) + (if pk.meta { "Meta+" } else { "" })
            status_key.val = "Keys: ".to_string() + mods_label + pk.name
            false
          }
          _ => false  // Let widgets handle keys by default
        }
      })
      app.cleanup()
    }
  }
}
