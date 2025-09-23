///| Event Loop - Handles input events and dispatches to components

///|
/// Main event loop that processes input and updates UI
pub fn run_event_loop(
  app : @core.App,
  build_ui : () -> @view.View,
  on_global_event? : (@ffi.InputEvent) -> Bool = fn(_) { false },
) -> Unit {
  // Enable raw mode for input (already enabled by new())
  let session = @ffi.TerminalSession::new(raw_mode=true, mouse=true)

  // Mouse tracking already enabled by session

  // Track if we need to redraw
  let needs_redraw = Ref::new(true)
  let running = Ref::new(true)

  // Track current UI and layout for event dispatch
  let current_ui : Ref[@view.View?] = Ref::new(None)
  let current_layout : Ref[@yoga.Node?] = Ref::new(None)
  let focused_view_id : Ref[Int?] = Ref::new(None)
  // Focus position within traversal order of focusables (pre-order)
  let focused_pos : Ref[Int?] = Ref::new(None)

  // Frame timing (target 60 FPS = ~16ms per frame)
  let frame_time_ms = 16

  // Dimensions are now stored in the app and updated on resize

  while running.val {
    // Poll for input events (always try to read)
    let event = @ffi.poll_input_event()

    // Handle system events
    match event {
      @ffi.InputEvent::Key(@ffi.KeyEvent::Char(3)) =>
        // Ctrl+C to quit
        running.val = false
      @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) =>
        // ESC to quit
        running.val = false
      @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) =>
        // 'q' to quit (unless handled by app)
        if not(on_global_event(event)) {
          running.val = false
        }
      @ffi.InputEvent::Resize(new_w, new_h) => {
        // Update app dimensions
        app.resize(new_w, new_h)
        // Force redraw with new dimensions
        needs_redraw.val = true
      }
      @ffi.InputEvent::MouseDown(x, y, _button) => {
        // Dispatch click to view
        match (current_ui.val, current_layout.val) {
          (Some(ui), Some(layout)) =>
            if dispatch_click(ui, x, y, layout) {
              needs_redraw.val = true
            }
          _ => ()
        }
        // Also let global handler process it
        if on_global_event(event) {
          needs_redraw.val = true
        }
      }
      @ffi.InputEvent::Key(key) => {
        // First try to dispatch to focused view
        let handled = match (current_ui.val, focused_view_id.val) {
          (Some(ui), Some(_)) =>
            dispatch_key_event(ui, key, focused_view_id.val)
          _ => false
        }

        // Handle Tab for focus navigation
        if not(handled) {
          match key {
            @ffi.KeyEvent::Tab =>
              match current_ui.val {
                Some(ui) => {
                  let ids = collect_focusable_ids(ui)
                  if ids.length() > 0 {
                    let new_pos = match focused_pos.val {
                      Some(pos) => (pos + 1) % ids.length()
                      None => 0
                    }
                    // Clear all focus then set new focus by index
                    clear_all_focus(ui)
                    let new_id = ids[new_pos]
                    let _ = set_view_focused(ui, Some(new_id), true)
                    focused_view_id.val = Some(new_id)
                    focused_pos.val = Some(new_pos)
                    needs_redraw.val = true
                  }
                }
                None => ()
              }
            _ =>
              // Let global handler process it
              if on_global_event(event) {
                needs_redraw.val = true
              }
          }
        } else {
          needs_redraw.val = true
        }
      }
      @ffi.InputEvent::None =>
        // No input available, continue
        ()
      _ =>
        // Let the app handle other events globally
        if on_global_event(event) {
          needs_redraw.val = true
        }
    }

    // Redraw if needed
    if needs_redraw.val {
      // Clear and rebuild UI
      app.clear(0.05, 0.05, 0.1)

      // Build UI tree
      let ui = build_ui()

      // Store current UI for event dispatch
      current_ui.val = Some(ui)

      // Ensure focus after rebuild using traversal index if present
      match focused_pos.val {
        Some(pos) => {
          let ids = collect_focusable_ids(ui)
          if ids.length() > 0 {
            let clamped = if pos >= ids.length() {
              ids.length() - 1
            } else {
              pos
            }
            clear_all_focus(ui)
            let new_id = ids[clamped]
            let _ = set_view_focused(ui, Some(new_id), true)
            focused_view_id.val = Some(new_id)
            focused_pos.val = Some(clamped)
          }
        }
        None => ()
      }

      // Calculate layout with Yoga using current app dimensions
      let yoga_root = @layout.calculate_layout(
        ui,
        app.width.to_double().to_float(),
        app.height.to_double().to_float(),
      )

      // Store current layout for event dispatch
      current_layout.val = Some(yoga_root)

      // Render with computed layout
      @layout.render_with_layout(app, ui, yoga_root, 0, 0)

      // Present to screen
      app.render()
      needs_redraw.val = false
    }

    // Frame rate limiting
    @ffi.sleep_ms(frame_time_ms)
  }

  // Cleanup
  match session {
    Some(s) => s.cleanup()
    None => ()
  }
}
