///| Select component demo

pub fn run_select_demo() -> Unit {
  println("=== OneBit-TUI Select Demo ===")
  println("Use ↑/↓ to navigate, Enter/Space to select, ESC to close dropdown. q to quit.")
  
  // Create select items
  let items = [
    @components.SelectItem::{ label: "Apple", value: "apple", disabled: false },
    @components.SelectItem::{ label: "Banana", value: "banana", disabled: false },
    @components.SelectItem::{ label: "Cherry", value: "cherry", disabled: false },
    @components.SelectItem::{ label: "Date (disabled)", value: "date", disabled: true },
    @components.SelectItem::{ label: "Elderberry", value: "elderberry", disabled: false },
    @components.SelectItem::{ label: "Fig", value: "fig", disabled: false },
    @components.SelectItem::{ label: "Grape", value: "grape", disabled: false },
  ]
  
  // Create select component
  let select = @components.Select::new(
    items,
    placeholder="Choose a fruit...",
    max_visible_items=5,
    on_change=Some(fn(value) -> Unit {
      println("Selected: " + value)
    })
  )
  
  let width = 80
  let height = 24
  
  match @ffi.Renderer::new(width.reinterpret_as_uint(), height.reinterpret_as_uint()) {
    None => {
      println("Failed to initialize renderer")
      return
    }
    Some(r) => {
      ignore(@ffi.set_terminal_raw_mode())
      
      let mut running = true
      let mut last_action = "None"
      
      while running {
        let buffer = r.get_next_buffer()
        buffer.clear(0.05, 0.05, 0.1, 1.0)
        
        // Draw title
        buffer.draw_text(
          "Select Component Demo",
          30_U, 2_U,
          fg_r=0.8, fg_g=0.8, fg_b=1.0,
          bold=true
        )
        
        // Draw the select component
        select.render(buffer, 25, 8, 30, true)
        
        // Draw status
        buffer.draw_text(
          "Last action: " + last_action,
          2_U, (height - 2).reinterpret_as_uint(),
          fg_r=0.6, fg_g=0.6, fg_b=0.6
        )
        
        // Draw current selection
        match select.selected_item() {
          Some(item) => {
            buffer.draw_text(
              "Current selection: " + item.label,
              25_U, 6_U,
              fg_r=0.7, fg_g=0.9, fg_b=0.7
            )
          }
          None => {
            buffer.draw_text(
              "No selection",
              25_U, 6_U,
              fg_r=0.7, fg_g=0.7, fg_b=0.7
            )
          }
        }
        
        r.render(force=false)
        
        // Handle input
        match @ffi.poll_input_event() {
          @ffi.InputEvent::Key(key) => {
            match key {
              @ffi.KeyEvent::Char(113) | @ffi.KeyEvent::Char(81) => { // q/Q
                running = false
                last_action = "Quit"
              }
              _ => {
                if select.handle_key(key) {
                  match key {
                    @ffi.KeyEvent::Enter => last_action = "Enter"
                    @ffi.KeyEvent::Escape => last_action = "Escape"
                    @ffi.KeyEvent::ArrowUp => last_action = "Up"
                    @ffi.KeyEvent::ArrowDown => last_action = "Down"
                    @ffi.KeyEvent::Char(32) => last_action = "Space"
                    _ => ()
                  }
                }
              }
            }
          }
          _ => ()
        }
      }
      
      r.destroy()
      ignore(@ffi.restore_terminal_mode())
    }
  }
}