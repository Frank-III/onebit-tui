///| Interactive Yoga layout demo

fn run_yoga_interactive_demo() -> Unit {
  // Build a simple view tree
  let view = box(
    title=Some("Yoga Interactive"),
    padding=2,
    children=[
      vstack([
        text("Use ←/→ to move, Space to toggle, q to quit"),
        hstack([
          text("Left"),
          text("Right")
        ])
      ])
    ]
  )

  // Init renderer
  match @ffi.Renderer::new(80, 24) {
    None => { println("Failed to initialize renderer"); return }
    Some(renderer) => {
      ignore(@ffi.set_terminal_raw_mode())
      let mut running = true
      let mut selected = 0
      let fm = FocusManager::new(0)
      let mut toggled = false

      while running {
        // Compute layout and flatten leaves
        let buffer = renderer.get_next_buffer()
        buffer.clear(0.05, 0.05, 0.1, 1.0)
        let bounds = Rect::new(0, 0, 80, 24)
        let items = flatten_layout(view, bounds)
        fm.set_count(items.length())
        match fm.get_focused() {
          Some(i) => selected = i
          None => ()
        }
        // Clamp selection
        if items.length() == 0 { running = false; break }
        if selected >= items.length() { selected = items.length() - 1 }

        // Draw view
        render_view_to_buffer(view, buffer, bounds)

        // Overlay highlight for selected leaf
        let sb = items[selected].bounds
        // Simple border box
        // top
        buffer.fill_rect(sb.x.reinterpret_as_uint(), sb.y.reinterpret_as_uint(), sb.width.reinterpret_as_uint(), 1_U, 0.9, 0.9, 0.2, 1.0)
        // bottom
        buffer.fill_rect(sb.x.reinterpret_as_uint(), (sb.y + sb.height - 1).reinterpret_as_uint(), sb.width.reinterpret_as_uint(), 1_U, 0.9, 0.9, 0.2, 1.0)
        // left
        buffer.fill_rect(sb.x.reinterpret_as_uint(), sb.y.reinterpret_as_uint(), 1_U, sb.height.reinterpret_as_uint(), 0.9, 0.9, 0.2, 1.0)
        // right
        buffer.fill_rect((sb.x + sb.width - 1).reinterpret_as_uint(), sb.y.reinterpret_as_uint(), 1_U, sb.height.reinterpret_as_uint(), 0.9, 0.9, 0.2, 1.0)

        if toggled {
          // fill inside slightly
          let ix = (sb.x + 1).reinterpret_as_uint()
          let iy = (sb.y + 1).reinterpret_as_uint()
          let iw = (sb.width - 2).reinterpret_as_uint()
          let ih = (sb.height - 2).reinterpret_as_uint()
          buffer.fill_rect(ix, iy, iw, ih, 0.2, 0.4, 0.6, 0.3)
        }

        renderer.render(force=false)

        // Handle input
        let ev = @ffi.poll_input_event()
        match ev {
          @ffi.InputEvent::Key(key) => {
            match key {
              @ffi.KeyEvent::ArrowLeft => {
                fm.prev()
                match fm.get_focused() {
                  Some(i) => selected = i
                  None => ()
                }
              }
              @ffi.KeyEvent::ArrowRight => {
                fm.next()
                match fm.get_focused() {
                  Some(i) => selected = i
                  None => ()
                }
              }
              @ffi.KeyEvent::Char(c) => {
                if c == 113 { running = false } // 'q'
                if c == 32 { toggled = not(toggled) } // Space
              }
              @ffi.KeyEvent::Escape => { running = false }
              _ => ()
            }
          }
          @ffi.InputEvent::MouseDown(mx, my, _) => {
            match hit_test(mx, my, items) {
              Some(idx) => { fm.focus(idx); selected = idx }
              None => ()
            }
          }
          _ => ()
        }

        @ffi.sleep_ms(16)
      }
      let _ = @ffi.restore_terminal_mode()
      renderer.destroy()
    }
  }
}

// Provide a file-local main so `moon run src/demo/yoga_interactive_demo.mbt` works
// fn main {
//   run_yoga_interactive_demo()
// }
