///| Minimal synchronous event loop for OneBit-TUI
///| Mirrors the async style seen in async-moonbit (with_event_loop),
///| but avoids external deps by using non-blocking poll + sleep pacing.

pub fn run_event_loop(
  app : @core.App,
  root : View,
  focused_id? : Ref[Int] = Ref::new(0),
  fps? : Int = 30,
) -> Unit {
  let frame_ms = if fps <= 0 { 33 } else { 1000 / fps }
  let mut running = true
  // Set up terminal session: raw mode + mouse + resize
  let session_opt = @ffi.TerminalSession::new(raw_mode=true, mouse=true, mouse_movement=false, resize_detection=true)
  let mut ui = root

  while running {
    // Ensure we have an initial focus target
    if focused_id.val == 0 {
      let first = find_first_interactive_id(ui)
      if first > 0 { focused_id.val = first }
      else {
        let ids = collect_focusable(ui)
        if ids.length() > 0 { focused_id.val = ids[0] }
      }
    }
    // Render frame with focus ring
    app.clear(0.05, 0.05, 0.10)
    // Hide terminal cursor (renderer-scoped; visible=false)
    app.get_renderer().cursor(0, 0, visible=false)
    render_view_with_focus(app, ui, focused_id.val)

    // Drain input events this frame
    while true {
      let ev = @ffi.poll_input_event()
      match ev {
        @ffi.InputEvent::None => break
        @ffi.InputEvent::Resize(w, h) => {
          app.get_renderer().resize(w, h)
          break // let next frame recalc layout via render_view
        }
        @ffi.InputEvent::Key(key) => {
          // Default exit on Ctrl+C or 'q' (customize as needed)
          match key {
            @ffi.KeyEvent::Char(code) => {
              if code == 113 { // 'q'
                running = false
              }
            }
            @ffi.KeyEvent::PageUp => { if focused_id.val > 0 { ui = adjust_view_scroll(ui, focused_id.val, -5) } }
            @ffi.KeyEvent::PageDown => { if focused_id.val > 0 { ui = adjust_view_scroll(ui, focused_id.val, 5) } }
            _ => ()
          }
          // Dispatch to focused view (Tab handled in handle_input_event)
          ignore(handle_input_event(ui, focused_id, ev))
        }
        @ffi.InputEvent::KeyMod(key, mods) => {
          // Exit on 'q' regardless of modifiers
          match key {
            @ffi.KeyEvent::Char(code) => { if code == 113 { running = false } }
            @ffi.KeyEvent::PageUp => { if focused_id.val > 0 { ui = adjust_view_scroll(ui, focused_id.val, -5) } }
            @ffi.KeyEvent::PageDown => { if focused_id.val > 0 { ui = adjust_view_scroll(ui, focused_id.val, 5) } }
            _ => ()
          }
          ignore(handle_input_event(ui, focused_id, @ffi.InputEvent::KeyMod(key, mods)))
        }
        @ffi.InputEvent::MouseDown(x, y, btn) => {
          // Update focus to clicked view if any
          let id = app.get_renderer().check_hit(x, y)
          if id > 0 { focused_id.val = id }
          match btn {
            @ffi.MouseButton::ScrollUp => { if focused_id.val > 0 { ui = adjust_view_scroll(ui, focused_id.val, -1) } }
            @ffi.MouseButton::ScrollDown => { if focused_id.val > 0 { ui = adjust_view_scroll(ui, focused_id.val, 1) } }
            _ => dispatch_click(app, ui, x, y)
          }
        }
        _ => ()
      }
    }

    @ffi.sleep_ms(frame_ms)
  }

  // Cleanup terminal session if it was created
  match session_opt {
    Some(sess) => sess.cleanup()
    None => ()
  }
}
