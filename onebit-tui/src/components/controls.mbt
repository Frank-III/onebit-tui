///| Small, composable controls built from View + text

/// Button (composable)
pub fn make_button(label : String, primary : Bool, on_click : () -> Unit) -> View {
  let bg = if primary { @core.Color::Blue } else { @core.Color::Gray }
  let fg = if primary { @core.Color::BrightWhite } else { @core.Color::White }
  View::new()
    .padding(1.0)
    .background(bg)
    .border(BorderStyle::Single, bg)
    .on_click(fn(_, _) { on_click() })
    .children([
      View::text(label, Some(fg))
    ])
}

/// Text input (display-only for now)
pub fn input_control(value : Ref[String], placeholder? : String = "") -> View {
  let has_text = value.val.length() > 0
  let display = if has_text { value.val } else { placeholder }
  let color = if has_text { @core.Color::White } else { @core.Color::Gray }
  View::new()
    .padding(1.0)
    .border(BorderStyle::Single, @core.Color::Gray)
    .children([
      View::text(display, Some(color))
    ])
}

/// Vertical list (highlight selected)
pub fn vlist(items : Array[String], selected : Ref[Int]) -> View {
  let rows : Array[View] = []
  for i = 0; i < items.length(); i = i + 1 {
    let idx = i // capture index
    let row = View::new()
      .row()
      .children([
        // Dynamically render prefix based on current selection
        View::new().text_bind(fn() {
          if idx == selected.val { "> " + items[idx] } else { "  " + items[idx] }
        }, color=@core.Color::White)
      ])
      .on_click(fn(_, _) { selected.val = idx })
    rows.push(row)
  }
  vbox(rows)
}

// --- Helpers for string editing ---

fn str_sub(s : String, start : Int, end : Int) -> String {
  if start < 0 || end <= start { return "" }
  let mut i = if start > s.length() { s.length() } else { start }
  let stop = if end > s.length() { s.length() } else { end }
  let mut out = ""
  while i < stop {
    match s[i].to_char() {
      Some(ch) => out = out + ch.to_string()
      None => ()
    }
    i = i + 1
  }
  out
}

fn clamp(n : Int, lo : Int, hi : Int) -> Int {
  if n < lo { lo } else if n > hi { hi } else { n }
}

/// Editable text input with caret
pub fn input_edit(value : Ref[String], caret? : Ref[Int] = Ref::new(0), placeholder? : String = "") -> View {
  // Ensure caret is within bounds initially
  caret.val = clamp(caret.val, 0, value.val.length())

  let has_text = fn() { value.val.length() > 0 }

  let view = View::new()
    .focusable()
    .wrap_to_layout()
    .padding(1.0)
    .border(BorderStyle::Single, @core.Color::Gray)
    .text_bind(fn() {
      if has_text() { value.val } else { placeholder }
    }, color=if has_text() { @core.Color::White } else { @core.Color::Gray })
    .cursor_bind(fn() { caret.val }, visible_provider=fn() { has_text() })
    .on_key_mod(fn(key, _mods) {
      match key {
        @ffi.KeyEvent::Char(code) => {
          // Printable ASCII range; ignore control characters
          if code >= 32 && code <= 126 {
            match code.to_char() {
              Some(ch) => {
                let len = value.val.length()
                let pos = clamp(caret.val, 0, len)
                let before = str_sub(value.val, 0, pos)
                let after = str_sub(value.val, pos, len)
                value.val = before + ch.to_string() + after
                caret.val = pos + 1
              }
              None => ()
            }
            true
          } else { false }
        }
        @ffi.KeyEvent::Backspace => {
          let len = value.val.length()
          if len > 0 && caret.val > 0 {
            let pos = caret.val - 1
            let before = str_sub(value.val, 0, pos)
            let after = str_sub(value.val, caret.val, len)
            value.val = before + after
            caret.val = pos
          }
          true
        }
        @ffi.KeyEvent::Delete => {
          let len = value.val.length()
          if caret.val < len {
            let before = str_sub(value.val, 0, caret.val)
            let after = str_sub(value.val, caret.val + 1, len)
            value.val = before + after
          }
          true
        }
        @ffi.KeyEvent::ArrowLeft => { caret.val = clamp(caret.val - 1, 0, value.val.length()); true }
        @ffi.KeyEvent::ArrowRight => { caret.val = clamp(caret.val + 1, 0, value.val.length()); true }
        @ffi.KeyEvent::Home => { caret.val = 0; true }
        @ffi.KeyEvent::End => { caret.val = value.val.length(); true }
        _ => false
      }
    })

  view
}
