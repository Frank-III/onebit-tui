///| Demo showing App wrapper with Yoga layout integration
///| This combines the clean App API with powerful Yoga flexbox layout


fn main() -> Unit {
  // Component state
  let selected_index = Ref::new(0)
  let items = ["Dashboard", "Projects", "Settings", "Help", "About"]
  
  // Yoga nodes that will be created
  let header_node = Ref::new(@wrapper.Node?)
  let sidebar_node = Ref::new(@wrapper.Node?)
  let content_node = Ref::new(@wrapper.Node?)
  let footer_node = Ref::new(@wrapper.Node?)
  
  App::new()
    .title("App with Yoga Layout")
    .size(120, 40)
    .with_yoga(true)  // Enable Yoga layout!
    .on_layout(fn(_app, root) {
      // Build the layout tree using Yoga's fluent API
      root.set_flex_direction(@types.FlexDirection::Column)
      root.set_padding(@types.Edge::All, 1.0)
      
      // Header (fixed height)
      let header = @wrapper.NodeBuilder::new()
        .height(5.0)
        .width_percent(100.0)
        .margin_bottom(1.0)
        .build()
      header_node.val = Some(header)
      
      // Main content area (flex grow)
      let main_area = @wrapper.NodeBuilder::row()
        .flex_grow(1.0)
        .width_percent(100.0)
        .build()
      
      // Sidebar (fixed width)
      let sidebar = @wrapper.NodeBuilder::column()
        .width(30.0)
        .height_percent(100.0)
        .margin_right(2.0)
        .build()
      sidebar_node.val = Some(sidebar)
      
      // Content area (flex grow)
      let content = @wrapper.NodeBuilder::column()
        .flex_grow(1.0)
        .height_percent(100.0)
        .padding(2.0)
        .build()
      content_node.val = Some(content)
      
      // Footer (fixed height)
      let footer = @wrapper.NodeBuilder::new()
        .height(3.0)
        .width_percent(100.0)
        .margin_top(1.0)
        .build()
      footer_node.val = Some(footer)
      
      // Build the tree
      main_area.add_child(sidebar)
      main_area.add_child(content)
      
      root.add_child(header)
      root.add_child(main_area)
      root.add_child(footer)
    })
    .on_key(Key::ArrowUp, fn() {
      if selected_index.val > 0 {
        selected_index.val = selected_index.val - 1
      }
    })
    .on_key(Key::ArrowDown, fn() {
      if selected_index.val < items.length() - 1 {
        selected_index.val = selected_index.val + 1
      }
    })
    .on_update(fn(app, buffer) {
      // Get calculated layouts from Yoga
      match header_node.val {
        Some(node) => {
          let layout = node.get_layout()
          draw_box(
            buffer,
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int(),
            "Header - Yoga Layout Demo",
            RGBA::cyan()
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            layout.top.to_int() + 2,
            "Yoga provides flexible, powerful layout calculations",
            RGBA::yellow(),
            RGBA::transparent(),
            TextStyle::None
          )
        }
        None => ()
      }
      
      match sidebar_node.val {
        Some(node) => {
          let layout = node.get_layout()
          draw_box(
            buffer,
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int(),
            "Sidebar",
            RGBA::blue()
          )
          
          // Draw menu items
          for i = 0; i < items.length(); i = i + 1 {
            let color = if i == selected_index.val {
              RGBA::yellow()
            } else {
              RGBA::white()
            }
            
            let prefix = if i == selected_index.val { "▶ " } else { "  " }
            
            buffer.write_string(
              layout.left.to_int() + 2,
              layout.top.to_int() + 2 + i * 2,
              prefix + items[i],
              color,
              RGBA::transparent(),
              TextStyle::None
            )
          }
        }
        None => ()
      }
      
      match content_node.val {
        Some(node) => {
          let layout = node.get_layout()
          draw_box(
            buffer,
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int(),
            "Content Area",
            RGBA::green()
          )
          
          // Content based on selection
          let content_text = match selected_index.val {
            0 => "Dashboard: View your analytics and metrics"
            1 => "Projects: Manage your active projects"
            2 => "Settings: Configure your preferences"
            3 => "Help: Get assistance and documentation"
            4 => "About: Learn more about OneBit-TUI"
            _ => "Unknown"
          }
          
          buffer.write_string(
            layout.left.to_int() + 2,
            layout.top.to_int() + 2,
            content_text,
            RGBA::white(),
            RGBA::transparent(),
            TextStyle::None
          )
          
          // Show layout info
          buffer.write_string(
            layout.left.to_int() + 2,
            layout.top.to_int() + 4,
            "Layout calculated by Yoga:",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            layout.top.to_int() + 5,
            "  Position: (\{layout.left.to_int()}, \{layout.top.to_int()})",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            layout.top.to_int() + 6,
            "  Size: \{layout.width.to_int()}x\{layout.height.to_int()}",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
        }
        None => ()
      }
      
      match footer_node.val {
        Some(node) => {
          let layout = node.get_layout()
          draw_box(
            buffer,
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int(),
            "Footer",
            RGBA::magenta()
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            layout.top.to_int() + 1,
            "↑↓ Navigate | Q/ESC Quit | Frame: \{app.get_frame_count()}",
            RGBA::white(),
            RGBA::transparent(),
            TextStyle::None
          )
        }
        None => ()
      }
    })
    .run()
}

// Helper to draw a box with border
fn draw_box(
  buffer : @ffi.TextBuffer,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  title : String,
  color : RGBA
) -> Unit {
  // Top border
  buffer.write_string(x, y, "╭", color, RGBA::transparent(), TextStyle::None)
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_string(x + i, y, "─", color, RGBA::transparent(), TextStyle::None)
  }
  buffer.write_string(x + width - 1, y, "╮", color, RGBA::transparent(), TextStyle::None)
  
  // Title
  if title.length() > 0 {
    let title_with_brackets = "┤ " + title + " ├"
    let title_x = x + (width - title_with_brackets.length()) / 2
    buffer.write_string(title_x, y, title_with_brackets, color, RGBA::transparent(), TextStyle::Bold)
  }
  
  // Side borders
  for i = 1; i < height - 1; i = i + 1 {
    buffer.write_string(x, y + i, "│", color, RGBA::transparent(), TextStyle::None)
    buffer.write_string(x + width - 1, y + i, "│", color, RGBA::transparent(), TextStyle::None)
  }
  
  // Bottom border
  buffer.write_string(x, y + height - 1, "╰", color, RGBA::transparent(), TextStyle::None)
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_string(x + i, y + height - 1, "─", color, RGBA::transparent(), TextStyle::None)
  }
  buffer.write_string(x + width - 1, y + height - 1, "╯", color, RGBA::transparent(), TextStyle::None)
}