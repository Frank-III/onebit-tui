///| Advanced Demo with Mouse Support and Terminal Resize Handling
///| Shows full input event handling in MoonBit style

struct UIState {
  mut width : UInt
  mut height : UInt
  mut mouse_x : Int
  mut mouse_y : Int
  mut mouse_down : Bool
  mut last_button : @ffi.MouseButton
  mut selected_item : Int
  mut resize_count : Int
  event_log : FixedArray[String]
  mut log_index : Int
}

pub fn run_mouse_resize_demo() -> Unit {
  println("=== OneBit-TUI Advanced Input Demo ===")
  println("Features:")
  println("  🖱️  Full mouse support (click, drag, scroll)")
  println("  📐 Terminal resize detection")
  println("  ⌨️  Extended keyboard (F-keys, Page Up/Down, etc)")
  println("")
  println("Press any key to start (ESC to quit)...")
  
  // Create terminal session with all features
  match @ffi.TerminalSession::new(
    raw_mode=true,
    mouse=true,
    mouse_movement=true,
    resize_detection=true
  ) {
    None => {
      println("Failed to initialize terminal session")
      return
    }
    Some(session) => {
      // Get initial terminal size
      let (width, height) = @ffi.get_terminal_size()
      
      // Initialize UI state
      let state = UIState::{
        width,
        height,
        mouse_x: -1,
        mouse_y: -1,
        mouse_down: false,
        last_button: @ffi.MouseButton::None,
        selected_item: 0,
        resize_count: 0,
        event_log: FixedArray::make(10, ""),
        log_index: 0
      }
      
      // Initialize renderer
      match @ffi.Renderer::new(width, height) {
        None => {
          session.cleanup()
          println("Failed to initialize renderer")
          return
        }
        Some(renderer) => {
          run_demo(renderer, state)
          
          // Clean up
          renderer.destroy()
          session.cleanup()
          
          println("\nDemo completed!")
          println("Resize events: " + state.resize_count.to_string())
        }
      }
    }
  }
}

fn run_demo(renderer : @ffi.Renderer, state : UIState) -> Unit {
  renderer.set_use_thread(true)
  renderer.set_background_color(0.05, 0.05, 0.15, 1.0)
  
  let mut running = true
  let mut frame = 0
  
  // Menu items for interaction
  let menu_items = FixedArray::make(5, "")
  menu_items[0] = "File"
  menu_items[1] = "Edit"
  menu_items[2] = "View"
  menu_items[3] = "Tools"
  menu_items[4] = "Help"
  let menu_count = 5
  
  while running {
    // Poll for events
    let event = @ffi.poll_input_event()
    
    // Handle events
    match event {
      @ffi.InputEvent::Key(key) => {
        match key {
          @ffi.KeyEvent::Escape => {
            running = false
            add_event_log(state, "ESC pressed - exiting")
          }
          @ffi.KeyEvent::ArrowLeft => {
            if state.selected_item > 0 {
              state.selected_item = state.selected_item - 1
              add_event_log(state, "Selected: " + menu_items[state.selected_item])
            }
          }
          @ffi.KeyEvent::ArrowRight => {
            if state.selected_item < menu_count - 1 {
              state.selected_item = state.selected_item + 1
              add_event_log(state, "Selected: " + menu_items[state.selected_item])
            }
          }
          @ffi.KeyEvent::F(n) => {
            add_event_log(state, "F" + n.to_string() + " pressed")
          }
          @ffi.KeyEvent::PageUp => {
            add_event_log(state, "Page Up")
          }
          @ffi.KeyEvent::PageDown => {
            add_event_log(state, "Page Down")
          }
          @ffi.KeyEvent::Char(c) => {
            if c == 113 {  // 'q'
              running = false
              add_event_log(state, "Quit requested")
            } else {
              add_event_log(state, "Key: " + char_to_string(c))
            }
          }
          _ => ()
        }
      }
      
      @ffi.InputEvent::MouseMove(x, y) => {
        state.mouse_x = x
        state.mouse_y = y
      }
      
      @ffi.InputEvent::MouseDown(x, y, button) => {
        state.mouse_x = x
        state.mouse_y = y
        state.mouse_down = true
        state.last_button = button
        
        // Check if clicking on menu
        if y < 3 {
          let item = x / 12
          if item >= 0 && item < menu_count {
            state.selected_item = item
            add_event_log(state, "Clicked: " + menu_items[item])
          }
        }
        
        add_event_log(state, "Mouse down at " + x.to_string() + "," + y.to_string())
      }
      
      @ffi.InputEvent::MouseUp(x, y, button) => {
        state.mouse_x = x
        state.mouse_y = y
        state.mouse_down = false
        add_event_log(state, "Mouse up at " + x.to_string() + "," + y.to_string())
      }
      
      @ffi.InputEvent::MouseDrag(x, y, button) => {
        state.mouse_x = x
        state.mouse_y = y
        add_event_log(state, "Dragging to " + x.to_string() + "," + y.to_string())
      }
      
      @ffi.InputEvent::Resize(new_width, new_height) => {
        state.width = new_width
        state.height = new_height
        state.resize_count = state.resize_count + 1
        
        // Resize renderer
        renderer.resize(new_width, new_height)
        
        add_event_log(state, "Resized to " + new_width.to_string() + "x" + new_height.to_string())
      }
      
      _ => ()
    }
    
    // Render UI
    render_ui(renderer, state, menu_items, frame)
    
    frame = frame + 1
  }
}

fn render_ui(
  renderer : @ffi.Renderer,
  state : UIState,
  menu_items : FixedArray[String],
  frame : Int
) -> Unit {
  let buffer = renderer.get_next_buffer()
  buffer.clear(0.05, 0.05, 0.15, 1.0)
  
  // Draw title bar
  buffer.fill_rect(0_U, 0_U, state.width, 1_U, 0.1, 0.1, 0.3, 1.0)
  buffer.draw_text(
    "OneBit-TUI Advanced Demo - Frame " + frame.to_string(),
    2_U, 0_U,
    fg_r=1.0, fg_g=0.9, fg_b=0.7,
    bold=true
  )
  
  // Draw menu bar
  buffer.fill_rect(0_U, 1_U, state.width, 2_U, 0.15, 0.15, 0.25, 1.0)
  for i = 0; i < 5; i = i + 1 {
    let x = (i * 12 + 2).reinterpret_as_uint()
    let selected = i == state.selected_item
    
    if selected {
      buffer.fill_rect(x - 1_U, 1_U, 10_U, 2_U, 0.3, 0.3, 0.5, 1.0)
    }
    
    buffer.draw_text(
      menu_items[i],
      x, 1_U,
      fg_r=if selected { 1.0 } else { 0.8 },
      fg_g=if selected { 1.0 } else { 0.8 },
      fg_b=if selected { 1.0 } else { 0.8 },
      bold=selected
    )
  }
  
  // Draw terminal info panel
  draw_info_panel(buffer, state, 2_U, 4_U)
  
  // Draw event log panel
  draw_event_log(buffer, state, 2_U, 12_U)
  
  // Draw mouse cursor indicator
  if state.mouse_x >= 0 && state.mouse_y >= 0 {
    let mx = state.mouse_x.reinterpret_as_uint()
    let my = state.mouse_y.reinterpret_as_uint()
    
    if mx < state.width && my < state.height {
      if state.mouse_down {
        buffer.fill_rect(mx, my, 2_U, 1_U, 1.0, 0.5, 0.5, 0.8)
      } else {
        buffer.fill_rect(mx, my, 1_U, 1_U, 0.8, 0.8, 0.8, 0.5)
      }
    }
  }
  
  // Draw status bar
  let status = "Mouse: " + state.mouse_x.to_string() + "," + state.mouse_y.to_string() + 
               " | Size: " + state.width.to_string() + "x" + state.height.to_string() +
               " | Resizes: " + state.resize_count.to_string()
  
  buffer.fill_rect(0_U, state.height - 1_U, state.width, 1_U, 0.1, 0.1, 0.2, 1.0)
  buffer.draw_text(
    status,
    2_U, state.height - 1_U,
    fg_r=0.7, fg_g=0.7, fg_b=0.9
  )
  
  renderer.render(force=false)
}

fn draw_info_panel(buffer : @ffi.Buffer, state : UIState, x : UInt, y : UInt) -> Unit {
  // Draw box border
  let border_chars = FixedArray::make(6, 0_U)
  border_chars[0] = 0x250C_U // ┌
  border_chars[1] = 0x2500_U // ─
  border_chars[2] = 0x2510_U // ┐
  border_chars[3] = 0x2502_U // │
  border_chars[4] = 0x2514_U // └
  border_chars[5] = 0x2518_U // ┘
  
  let border_color = FixedArray::make(4, 0.0)
  border_color[0] = 0.3; border_color[1] = 0.5; border_color[2] = 0.7; border_color[3] = 1.0
  
  let bg_color = FixedArray::make(4, 0.0)
  bg_color[0] = 0.1; bg_color[1] = 0.1; bg_color[2] = 0.2; bg_color[3] = 1.0
  
  buffer.draw_box(
    x.reinterpret_as_int(), y.reinterpret_as_int(), 
    40_U, 6_U,
    border_chars, 
    pack_box_options(true, 2),  // fill=true, align=center
    border_color, bg_color,
    title=" Terminal Info "
  )
  
  // Draw info text
  buffer.draw_text("Terminal Size: " + state.width.to_string() + " x " + state.height.to_string(),
    x + 2_U, y + 1_U, fg_r=0.8, fg_g=0.8, fg_b=0.8)
  
  buffer.draw_text("Mouse Position: " + state.mouse_x.to_string() + ", " + state.mouse_y.to_string(),
    x + 2_U, y + 2_U, fg_r=0.8, fg_g=0.8, fg_b=0.8)
  
  let button_text = match state.last_button {
    @ffi.MouseButton::Left => "Left"
    @ffi.MouseButton::Middle => "Middle"
    @ffi.MouseButton::Right => "Right"
    @ffi.MouseButton::ScrollUp => "Scroll Up"
    @ffi.MouseButton::ScrollDown => "Scroll Down"
    _ => "None"
  }
  
  buffer.draw_text("Last Button: " + button_text,
    x + 2_U, y + 3_U, fg_r=0.8, fg_g=0.8, fg_b=0.8)
  
  buffer.draw_text("Resize Events: " + state.resize_count.to_string(),
    x + 2_U, y + 4_U, fg_r=0.8, fg_g=0.8, fg_b=0.8)
}

fn draw_event_log(buffer : @ffi.Buffer, state : UIState, x : UInt, y : UInt) -> Unit {
  // Draw box for event log
  let border_chars = FixedArray::make(6, 0_U)
  border_chars[0] = 0x250C_U // ┌
  border_chars[1] = 0x2500_U // ─
  border_chars[2] = 0x2510_U // ┐
  border_chars[3] = 0x2502_U // │
  border_chars[4] = 0x2514_U // └
  border_chars[5] = 0x2518_U // ┘
  
  let border_color = FixedArray::make(4, 0.0)
  border_color[0] = 0.5; border_color[1] = 0.3; border_color[2] = 0.3; border_color[3] = 1.0
  
  let bg_color = FixedArray::make(4, 0.0)
  bg_color[0] = 0.15; bg_color[1] = 0.1; bg_color[2] = 0.1; bg_color[3] = 1.0
  
  buffer.draw_box(
    x.reinterpret_as_int(), y.reinterpret_as_int(), 
    60_U, 8_U,
    border_chars, 
    pack_box_options(true, 2),  // fill=true, align=center
    border_color, bg_color,
    title=" Event Log "
  )
  
  // Draw log entries
  for i = 0; i < 6; i = i + 1 {
    let entry = state.event_log[i]
    if entry.length() > 0 {
      buffer.draw_text(
        entry,
        x + 2_U, y + (i + 1).reinterpret_as_uint(),
        fg_r=0.7, fg_g=0.9, fg_b=0.7
      )
    }
  }
}

fn add_event_log(state : UIState, message : String) -> Unit {
  // Shift entries up
  for i = 9; i > 0; i = i - 1 {
    state.event_log[i] = state.event_log[i - 1]
  }
  
  // Add new entry at front
  state.event_log[0] = message
}

fn char_to_string(c : Int) -> String {
  if c >= 32 && c <= 126 {
    // Printable ASCII - convert directly using Char
    c.unsafe_to_char().to_string()
  } else {
    // Non-printable
    "0x" + c.to_string()
  }
}

fn pack_box_options(fill : Bool, align : Int) -> UInt {
  let mut options = 0_U
  if fill {
    options = options.lor(1_U << 0)
  }
  options = options.lor(align.reinterpret_as_uint() << 8)
  options
}