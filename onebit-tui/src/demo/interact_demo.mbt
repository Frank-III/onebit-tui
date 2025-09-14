///| Interactive view demo using Yoga + event routing

fn run_interact_demo() -> Unit {
  println("=== OneBit-TUI Interact Demo ===")
  println("Use ←/→ to change focus, Enter/Space to activate, click to trigger. q/ESC to quit.")

  // Build a simple view: a boxed HStack of 5 interactable labels
  let mut last_action = "None"

  let mk_item = fn(i : Int) -> View {
    let label = text("Item " + (i + 1).to_string())
    let inner = box(padding=1, children=[ label ])
    interact(
      inner,
      on_click = Some(fn() -> Unit { println("Clicked Item " + (i + 1).to_string()) }),
      on_activate = Some(fn() -> Unit { println("Activated Item " + (i + 1).to_string()) })
    )
  }

  let view = box(
    title=Some("Interact Demo"),
    padding=1,
    children=[
      hstack(spacing=2, [
        mk_item(0), mk_item(1), mk_item(2), mk_item(3), mk_item(4)
      ])
    ]
  )

  // Init renderer
  let width = 80
  let height = 24
  match @ffi.Renderer::new(width.reinterpret_as_uint(), height.reinterpret_as_uint()) {
    None => { println("Failed to init renderer"); return }
    Some(r) => {
      ignore(@ffi.set_terminal_raw_mode())

      // Focus
      let fm = FocusManager::new(5)

      let bounds = Rect::new(0, 0, width, height)
      let mut running = true
      let mut frames = 0
      while running {
        let buffer = r.get_next_buffer()
        buffer.clear(0.05, 0.05, 0.10, 1.0)

        // Render view
        render_view_to_buffer(view, buffer, bounds)

        // Draw focus outline for current item
        let entries = collect_interact_handlers(view, bounds)
        match fm.get_focused() {
          Some(idx) => if entries.length() > 0 && idx >= 0 && idx < entries.length() {
            let b = entries[idx].bounds
            // simple highlight rectangle
            buffer.fill_rect(
              (b.x - 1).reinterpret_as_uint(), (b.y - 1).reinterpret_as_uint(),
              (b.width + 2).reinterpret_as_uint(), 1_U, 0.8, 0.8, 0.2, 1.0)
            buffer.fill_rect(
              (b.x - 1).reinterpret_as_uint(), (b.y + b.height).reinterpret_as_uint(),
              (b.width + 2).reinterpret_as_uint(), 1_U, 0.8, 0.8, 0.2, 1.0)
            buffer.fill_rect((b.x - 1).reinterpret_as_uint(), b.y.reinterpret_as_uint(), 1_U, b.height.reinterpret_as_uint(), 0.8, 0.8, 0.2, 1.0)
            buffer.fill_rect((b.x + b.width).reinterpret_as_uint(), b.y.reinterpret_as_uint(), 1_U, b.height.reinterpret_as_uint(), 0.8, 0.8, 0.2, 1.0)
          } else { () }
          None => ()
        }

        // Status line
        buffer.draw_text("Last: " + last_action, 2_U, (height - 2).reinterpret_as_uint(), fg_r=0.7, fg_g=0.7, fg_b=0.9)

        r.render(force=false)

        // Input
        match @ffi.poll_input_event() {
          @ffi.InputEvent::Key(k) => {
            match k {
              @ffi.KeyEvent::Escape => { running = false; last_action = "ESC" }
              @ffi.KeyEvent::Char(c) => {
                if c == 113 || c == 81 { running = false; last_action = "q" } // q/Q
                else if c == 32 { // Space
                  match fm.get_focused() { Some(idx) => if dispatch_activate(view, bounds, idx) { last_action = "Activate:" + (idx + 1).to_string() } else { () } ; None => () }
                }
              }
              @ffi.KeyEvent::Enter => { match fm.get_focused() { Some(idx) => if dispatch_activate(view, bounds, idx) { last_action = "Activate:" + (idx + 1).to_string() } else { () } ; None => () } }
              @ffi.KeyEvent::ArrowLeft => { FocusManager::prev(fm); last_action = "Prev" }
              @ffi.KeyEvent::ArrowRight => { FocusManager::next(fm); last_action = "Next" }
              _ => ()
            }
          }
          @ffi.InputEvent::MouseDown(x, y, _) => {
            if dispatch_mouse_click(view, bounds, x, y) { last_action = "Click @ (" + x.to_string() + "," + y.to_string() + ")" }
          }
          _ => ()
        }
        frames = frames + 1
        if frames > 200 { running = false } // auto-exit in non-interactive envs
      }

      r.destroy()
      ignore(@ffi.restore_terminal_mode())
    }
  }
}
