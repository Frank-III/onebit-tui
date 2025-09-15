///| Demo showcasing onebit-tui with onebit-yoga layout integration
///| This shows how Yoga handles responsive flexbox layouts with TUI components

fn main() -> Unit {
  // Initialize terminal
  let terminal = @ffi.get_terminal()
  terminal.clear()
  terminal.hide_cursor()
  terminal.enable_mouse(true)
  
  let (width, height) = terminal.get_size()
  
  // Create buffer
  let buffer = Buffer::new(width, height)
  let theme = Theme::default()
  buffer.theme = theme
  
  // Initialize Yoga
  let config = @yoga/wrapper.Config::new()
  config.set_use_web_defaults(true)
  
  // Create root Yoga node
  let root_yoga = @yoga/wrapper.Node::new_with_config(config)
  root_yoga.set_width(width.to_float())
  root_yoga.set_height(height.to_float())
  root_yoga.set_flex_direction(@yoga/types.FlexDirection::Column)
  root_yoga.set_padding(@yoga/types.Edge::All, 1.0)
  
  // Create header with Yoga
  let header_yoga = @yoga/wrapper.Node::new()
  header_yoga.set_height(5.0)
  header_yoga.set_margin(@yoga/types.Edge::Bottom, 1.0)
  
  // Create main content area with flex row
  let main_yoga = @yoga/wrapper.Node::new()
  main_yoga.set_flex_grow(1.0)
  main_yoga.set_flex_direction(@yoga/types.FlexDirection::Row)
  main_yoga.set_gap(@yoga/types.Gutter::Column, 2.0)
  
  // Left panel (1/3 width)
  let left_yoga = @yoga/wrapper.Node::new()
  left_yoga.set_flex(1.0)
  
  // Center panel (1/3 width)
  let center_yoga = @yoga/wrapper.Node::new()
  center_yoga.set_flex(1.0)
  
  // Right panel (1/3 width)
  let right_yoga = @yoga/wrapper.Node::new()
  right_yoga.set_flex(1.0)
  
  // Footer
  let footer_yoga = @yoga/wrapper.Node::new()
  footer_yoga.set_height(3.0)
  footer_yoga.set_margin(@yoga/types.Edge::Top, 1.0)
  
  // Build Yoga tree
  root_yoga.add_child(header_yoga)
  root_yoga.add_child(main_yoga)
  main_yoga.add_child(left_yoga)
  main_yoga.add_child(center_yoga)
  main_yoga.add_child(right_yoga)
  root_yoga.add_child(footer_yoga)
  
  // Calculate layout
  root_yoga.calculate_layout(@yoga/types.Undefined, @yoga/types.Undefined, @yoga/types.Direction::LTR)
  
  // Create TUI components based on Yoga layout
  
  // Header
  let header_layout = header_yoga.get_layout()
  let header_box = @components.Box::new("header")
    .with_border_style(BorderStyle::Double)
    .with_border_color(Color::cyan())
    .with_title("OneBit-TUI + Yoga Flexbox Layout")
    .with_dimensions(
      header_layout.left.to_int(),
      header_layout.top.to_int(),
      header_layout.width.to_int(),
      header_layout.height.to_int()
    )
  
  let header_text = @components.Text::new("header-text", "Responsive layout powered by Yoga")
    .with_align(TextAlign::Center)
    .with_foreground_color(Color::yellow())
    .with_dimensions(2, 1, header_box.base.width - 4, 1)
  
  header_box.add_child(header_text.as_renderable())
  
  // Left panel - List component
  let left_layout = left_yoga.get_layout()
  let left_box = @components.Box::new("left-panel")
    .with_border_style(BorderStyle::Single)
    .with_title("Navigation")
    .with_dimensions(
      left_layout.left.to_int(),
      left_layout.top.to_int(),
      left_layout.width.to_int(),
      left_layout.height.to_int()
    )
  
  let list = @components.List::new([
    @components.ListItem::new("Dashboard", "dashboard"),
    @components.ListItem::new("Components", "components"),
    @components.ListItem::new("Settings", "settings"),
    @components.ListItem::new("About", "about"),
  ])
  list.set_position(2, 2)
  list.set_size(left_box.base.width - 4, left_box.base.height - 4)
  
  left_box.add_child(list.as_renderable())
  
  // Center panel - Content area
  let center_layout = center_yoga.get_layout()
  let center_box = @components.Box::new("center-panel")
    .with_border_style(BorderStyle::Single)
    .with_title("Content")
    .with_dimensions(
      center_layout.left.to_int(),
      center_layout.top.to_int(),
      center_layout.width.to_int(),
      center_layout.height.to_int()
    )
  
  let content_text = @components.Text::new("content", 
    "This demo shows how Yoga's flexbox layout engine can be used with OneBit-TUI components.\n\n" +
    "The layout automatically adjusts to terminal size:\n" +
    "• Header and footer have fixed heights\n" +
    "• Main area uses flex-grow to fill space\n" +
    "• Three columns share width equally\n\n" +
    "Try resizing your terminal!")
    .with_wrap(TextWrap::Word)
    .with_foreground_color(Color::white())
    .with_dimensions(2, 2, center_box.base.width - 4, center_box.base.height - 4)
  
  center_box.add_child(content_text.as_renderable())
  
  // Right panel - Status/Info
  let right_layout = right_yoga.get_layout()
  let right_box = @components.Box::new("right-panel")
    .with_border_style(BorderStyle::Single)
    .with_title("Status")
    .with_dimensions(
      right_layout.left.to_int(),
      right_layout.top.to_int(),
      right_layout.width.to_int(),
      right_layout.height.to_int()
    )
  
  let status_group = @components.Group::new("status-group")
    .with_dimensions(2, 2, right_box.base.width - 4, right_box.base.height - 4)
  
  let term_size = @components.Text::new("term-size", "Terminal: \{width}x\{height}")
    .with_foreground_color(Color::green())
    .with_dimensions(0, 0, status_group.base.width, 1)
  
  let layout_info = @components.Text::new("layout-info", "Layout: Flexbox")
    .with_foreground_color(Color::green())
    .with_dimensions(0, 2, status_group.base.width, 1)
  
  let frame_counter = @components.Text::new("frame", "Frame: 0")
    .with_foreground_color(Color::green())
    .with_dimensions(0, 4, status_group.base.width, 1)
  
  status_group.add_child(term_size.as_renderable())
  status_group.add_child(layout_info.as_renderable())
  status_group.add_child(frame_counter.as_renderable())
  
  right_box.add_child(status_group.as_renderable())
  
  // Footer
  let footer_layout = footer_yoga.get_layout()
  let footer_box = @components.Box::new("footer")
    .with_border_style(BorderStyle::Single)
    .with_dimensions(
      footer_layout.left.to_int(),
      footer_layout.top.to_int(),
      footer_layout.width.to_int(),
      footer_layout.height.to_int()
    )
  
  let footer_text = @components.Text::new("footer-text", "Press 'q' to quit | Use arrows to navigate")
    .with_align(TextAlign::Center)
    .with_foreground_color(Color::white())
    .with_dimensions(2, 0, footer_box.base.width - 4, 1)
  
  footer_box.add_child(footer_text.as_renderable())
  
  // Create root group
  let root_group = @components.Group::new("root")
  root_group.add_child(header_box.as_renderable())
  root_group.add_child(left_box.as_renderable())
  root_group.add_child(center_box.as_renderable())
  root_group.add_child(right_box.as_renderable())
  root_group.add_child(footer_box.as_renderable())
  
  // Focus the list initially
  list.focus()
  
  // Main render loop
  let mut running = true
  let mut frame = 0
  let mut needs_layout = false
  
  while running {
    // Check for terminal resize
    let (new_width, new_height) = terminal.get_size()
    if new_width != width || new_height != height {
      needs_layout = true
    }
    
    if needs_layout {
      // Recalculate Yoga layout
      root_yoga.set_width(new_width.to_float())
      root_yoga.set_height(new_height.to_float())
      root_yoga.calculate_layout(@yoga/types.Undefined, @yoga/types.Undefined, @yoga/types.Direction::LTR)
      
      // Update component positions
      let header_layout = header_yoga.get_layout()
      header_box.base.x = header_layout.left.to_int()
      header_box.base.y = header_layout.top.to_int()
      header_box.base.width = header_layout.width.to_int()
      header_box.base.height = header_layout.height.to_int()
      
      let left_layout = left_yoga.get_layout()
      left_box.base.x = left_layout.left.to_int()
      left_box.base.y = left_layout.top.to_int()
      left_box.base.width = left_layout.width.to_int()
      left_box.base.height = left_layout.height.to_int()
      
      let center_layout = center_yoga.get_layout()
      center_box.base.x = center_layout.left.to_int()
      center_box.base.y = center_layout.top.to_int()
      center_box.base.width = center_layout.width.to_int()
      center_box.base.height = center_layout.height.to_int()
      
      let right_layout = right_yoga.get_layout()
      right_box.base.x = right_layout.left.to_int()
      right_box.base.y = right_layout.top.to_int()
      right_box.base.width = right_layout.width.to_int()
      right_box.base.height = right_layout.height.to_int()
      
      let footer_layout = footer_yoga.get_layout()
      footer_box.base.x = footer_layout.left.to_int()
      footer_box.base.y = footer_layout.top.to_int()
      footer_box.base.width = footer_layout.width.to_int()
      footer_box.base.height = footer_layout.height.to_int()
      
      // Update buffer size
      buffer.resize(new_width, new_height)
      
      // Update status text
      term_size.set_content("Terminal: \{new_width}x\{new_height}")
      
      needs_layout = false
    }
    
    // Update frame counter
    frame_counter.set_content("Frame: \{frame}")
    
    // Clear and render
    buffer.clear(Color::rgb(10, 10, 20))
    root_group.as_renderable().render(buffer)
    terminal.render_buffer(buffer)
    
    // Handle input
    match terminal.read_key() {
      Some(key) => {
        match key {
          "q" | "Q" => running = false
          "ArrowUp" | "ArrowDown" | "Enter" => {
            list.handle_key(key)
          }
          _ => ()
        }
      }
      None => ()
    }
    
    // Handle mouse
    match terminal.read_mouse() {
      Some(event) => {
        list.handle_mouse(event)
      }
      None => ()
    }
    
    frame += 1
    terminal.sleep(16) // ~60 FPS
  }
  
  // Cleanup
  terminal.disable_mouse()
  terminal.show_cursor()
  terminal.clear()
  
  // Free Yoga nodes
  root_yoga.free_recursive()
  config.free()
}