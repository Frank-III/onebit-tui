///| Comprehensive Demo: Yoga Layout + Event Loop + Components
///| This demonstrates the full capabilities of onebit-tui with MoonBit

fn main() -> Unit {
  println("=== OneBit-TUI Comprehensive Demo ===")
  println("Features:")
  println("  • Yoga flexbox layout")
  println("  • Interactive components (List, Select, Input)")
  println("  • Real-time event handling")
  println("  • Mouse support")
  println("")
  println("Controls:")
  println("  Tab: Switch focus between components")
  println("  ↑↓: Navigate in lists/selects")
  println("  Enter: Select item")
  println("  Mouse: Click on components")
  println("  q/ESC: Quit")
  println("")
  println("Press any key to start...")
  
  // Wait for key and set terminal to raw mode
  let _ = @ffi.read_key_byte()
  if @ffi.set_terminal_raw_mode() != 0 {
    println("Failed to set terminal to raw mode")
    return
  }
  
  // Initialize renderer
  match @ffi.Renderer::new(100, 40) {
    None => {
      let _ = @ffi.restore_terminal_mode()
      println("Failed to initialize renderer")
      return
    }
    Some(renderer) => {
      // Configure renderer
      renderer.set_use_thread(true)
      renderer.set_background_color(0.05, 0.05, 0.1, 1.0)
      renderer.enable_mouse(true)
      
      // Initialize Yoga for layout
      let yoga_config = @wrapper.Config::new()
      yoga_config.set_use_web_defaults(true)
      
      // Create root Yoga node
      let root_yoga = @wrapper.Node::new_with_config(yoga_config)
      root_yoga.set_width(100.0)
      root_yoga.set_height(40.0)
      root_yoga.set_flex_direction(@types.FlexDirection::Column)
      root_yoga.set_padding(@types.Edge::All, 2.0)
      
      // Create header with Yoga
      let header_yoga = @wrapper.Node::new()
      header_yoga.set_height(5.0)
      header_yoga.set_margin(@types.Edge::Bottom, 1.0)
      
      // Create main content area with 3 columns
      let main_yoga = @wrapper.Node::new()
      main_yoga.set_flex_grow(1.0)
      main_yoga.set_flex_direction(@types.FlexDirection::Row)
      main_yoga.set_gap(@types.Gutter::Column, 2.0)
      
      // Left column (30% width) - List
      let left_yoga = @wrapper.Node::new()
      left_yoga.set_flex(0.3)
      
      // Center column (40% width) - Form
      let center_yoga = @wrapper.Node::new()
      center_yoga.set_flex(0.4)
      
      // Right column (30% width) - Info
      let right_yoga = @wrapper.Node::new()
      right_yoga.set_flex(0.3)
      
      // Footer
      let footer_yoga = @wrapper.Node::new()
      footer_yoga.set_height(3.0)
      footer_yoga.set_margin(@types.Edge::Top, 1.0)
      
      // Build Yoga tree
      root_yoga.add_child(header_yoga)
      root_yoga.add_child(main_yoga)
      main_yoga.add_child(left_yoga)
      main_yoga.add_child(center_yoga)
      main_yoga.add_child(right_yoga)
      root_yoga.add_child(footer_yoga)
      
      // Calculate layout
      root_yoga.calculate_layout(@types.Undefined, @types.Undefined, @types.Direction::LTR)
      
      // Get calculated layouts
      let header_layout = header_yoga.get_layout()
      let left_layout = left_yoga.get_layout()
      let center_layout = center_yoga.get_layout()
      let right_layout = right_yoga.get_layout()
      let footer_layout = footer_yoga.get_layout()
      
      // Create components based on Yoga layout
      
      // Header
      let header_box = @components.Box::new("header")
      header_box.set_bounds(
        header_layout.left.to_int(),
        header_layout.top.to_int(),
        header_layout.width.to_int(),
        header_layout.height.to_int()
      )
      header_box.border_style = BorderStyle::Double
      header_box.border_color = RGBA::cyan()
      
      // List component in left column
      let list_items : Array[@components.ListItem] = [
        { id: "1", text: "Dashboard", icon: Some("📊"), data: Some("dashboard") },
        { id: "2", text: "Projects", icon: Some("📁"), data: Some("projects") },
        { id: "3", text: "Settings", icon: Some("⚙️"), data: Some("settings") },
        { id: "4", text: "Analytics", icon: Some("📈"), data: Some("analytics") },
        { id: "5", text: "Reports", icon: Some("📄"), data: Some("reports") },
        { id: "6", text: "Users", icon: Some("👥"), data: Some("users") },
        { id: "7", text: "Help", icon: Some("❓"), data: Some("help") }
      ]
      
      let list = @components.List::new("menu", list_items)
      list.set_bounds(
        left_layout.left.to_int(),
        left_layout.top.to_int(),
        left_layout.width.to_int(),
        left_layout.height.to_int()
      )
      list.border_style = BorderStyle::Single
      list.border_color = RGBA::blue()
      
      // Form in center column
      let form_box = @components.Box::new("form")
      form_box.set_bounds(
        center_layout.left.to_int(),
        center_layout.top.to_int(),
        center_layout.width.to_int(),
        center_layout.height.to_int()
      )
      form_box.border_style = BorderStyle::Single
      form_box.border_color = RGBA::green()
      
      // Info panel in right column
      let info_box = @components.Box::new("info")
      info_box.set_bounds(
        right_layout.left.to_int(),
        right_layout.top.to_int(),
        right_layout.width.to_int(),
        right_layout.height.to_int()
      )
      info_box.border_style = BorderStyle::Single
      info_box.border_color = RGBA::magenta()
      
      // Footer status
      let footer_box = @components.Box::new("footer")
      footer_box.set_bounds(
        footer_layout.left.to_int(),
        footer_layout.top.to_int(),
        footer_layout.width.to_int(),
        footer_layout.height.to_int()
      )
      footer_box.border_style = BorderStyle::Single
      footer_box.border_color = RGBA::white()
      
      // State management
      let mut focused_component = 0  // 0=list, 1=form, 2=info
      let mut running = true
      let mut status_message = "Ready"
      let mut selected_item = "None"
      let mut frame_count = 0
      
      // Setup component callbacks
      list.on_select = Some(fn(item) {
        selected_item = item.text
        status_message = "Selected: " + item.text
      })
      
      // Main event loop
      while running {
        // Get buffer
        let buffer = renderer.get_next_buffer()
        
        // Clear buffer
        buffer.clear(0.05, 0.05, 0.1, 1.0)
        
        // Render components
        header_box.render(buffer)
        buffer.write_string(
          header_layout.left.to_int() + 2,
          header_layout.top.to_int() + 1,
          "OneBit-TUI with Yoga Layout",
          RGBA::yellow(),
          RGBA::transparent(),
          TextStyle::Bold
        )
        buffer.write_string(
          header_layout.left.to_int() + 2,
          header_layout.top.to_int() + 2,
          "Frame: " + frame_count.to_string(),
          RGBA::gray(),
          RGBA::transparent(),
          TextStyle::None
        )
        
        list.render(buffer)
        form_box.render(buffer)
        info_box.render(buffer)
        footer_box.render(buffer)
        
        // Render status in footer
        buffer.write_string(
          footer_layout.left.to_int() + 2,
          footer_layout.top.to_int() + 1,
          status_message,
          RGBA::white(),
          RGBA::transparent(),
          TextStyle::None
        )
        
        // Render info panel content
        buffer.write_string(
          right_layout.left.to_int() + 2,
          right_layout.top.to_int() + 1,
          "Selected: " + selected_item,
          RGBA::white(),
          RGBA::transparent(),
          TextStyle::None
        )
        
        // Render the buffer
        renderer.render(force=false)
        
        // Handle input events
        if @ffi.is_input_available() {
          let key = @ffi.read_key_byte()
          
          match key {
            113 | 27 => {  // 'q' or ESC
              running = false
              status_message = "Exiting..."
            }
            9 => {  // Tab
              focused_component = (focused_component + 1) % 3
              status_message = "Focus: " + match focused_component {
                0 => "List"
                1 => "Form"
                2 => "Info"
                _ => "Unknown"
              }
            }
            65 => {  // Up arrow (simplified)
              if focused_component == 0 {
                list.select_previous()
              }
            }
            66 => {  // Down arrow (simplified)
              if focused_component == 0 {
                list.select_next()
              }
            }
            13 => {  // Enter
              if focused_component == 0 {
                list.trigger_select()
              }
            }
            _ => ()
          }
        }
        
        // Handle mouse events
        match renderer.get_mouse_event() {
          Some(event) => {
            // Check if click is within list bounds
            if event.x >= left_layout.left.to_int() && 
               event.x < left_layout.left.to_int() + left_layout.width.to_int() &&
               event.y >= left_layout.top.to_int() &&
               event.y < left_layout.top.to_int() + left_layout.height.to_int() {
              focused_component = 0
              // Calculate which item was clicked
              let item_index = event.y - left_layout.top.to_int() - 1
              if item_index >= 0 && item_index < list_items.length() {
                list.selected_index = item_index
                list.trigger_select()
              }
            }
          }
          None => ()
        }
        
        frame_count = frame_count + 1
        
        // Small delay for ~60 FPS
        @ffi.sleep_ms(16)
      }
      
      // Cleanup
      renderer.disable_mouse()
      renderer.destroy()
      let _ = @ffi.restore_terminal_mode()
      
      println("\nDemo completed!")
      println("Total frames: " + frame_count.to_string())
      println("Last selection: " + selected_item)
    }
  }
}

// Helper to create RGBA colors
fn RGBA::cyan() -> RGBA {
  RGBA::new(0.0, 1.0, 1.0, 1.0)
}

fn RGBA::blue() -> RGBA {
  RGBA::new(0.0, 0.5, 1.0, 1.0)
}

fn RGBA::green() -> RGBA {
  RGBA::new(0.0, 1.0, 0.0, 1.0)
}

fn RGBA::magenta() -> RGBA {
  RGBA::new(1.0, 0.0, 1.0, 1.0)
}

fn RGBA::yellow() -> RGBA {
  RGBA::new(1.0, 1.0, 0.0, 1.0)
}

fn RGBA::white() -> RGBA {
  RGBA::new(1.0, 1.0, 1.0, 1.0)
}

fn RGBA::gray() -> RGBA {
  RGBA::new(0.5, 0.5, 0.5, 1.0)
}

fn RGBA::transparent() -> RGBA {
  RGBA::new(0.0, 0.0, 0.0, 0.0)
}