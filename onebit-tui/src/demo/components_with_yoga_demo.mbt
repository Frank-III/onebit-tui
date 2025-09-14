///| Demo showing how OneBit-TUI components integrate with Yoga layout
///| Components position themselves based on Yoga's calculated layouts


fn main() -> Unit {
  // Create component references
  let header_box = Ref::new(@components.Box?)
  let menu_list = Ref::new(@components.List?)
  let select_component = Ref::new(@components.Select?)
  let info_text = Ref::new(@components.Text?)
  
  // Layout nodes
  let header_yoga = Ref::new(@wrapper.Node?)
  let sidebar_yoga = Ref::new(@wrapper.Node?)
  let main_yoga = Ref::new(@wrapper.Node?)
  let footer_yoga = Ref::new(@wrapper.Node?)
  
  App::new()
    .title("Components + Yoga Layout")
    .size(120, 40)
    .background(RGBA::new(0.02, 0.02, 0.05, 1.0))
    .with_yoga(true)
    .on_layout(fn(_app, root) {
      // Configure root
      root.set_flex_direction(@types.FlexDirection::Column)
      root.set_padding(@types.Edge::All, 2.0)
      root.set_gap(@types.Gutter::Row, 1.0)
      
      // Header: Fixed height
      let header = @wrapper.NodeBuilder::new()
        .height(7.0)
        .width_percent(100.0)
        .build()
      header_yoga.val = Some(header)
      root.add_child(header)
      
      // Main content: Row with sidebar and main area
      let content_row = @wrapper.NodeBuilder::row()
        .flex_grow(1.0)
        .width_percent(100.0)
        .gap(@types.Gutter::Column, 2.0)
        .build()
      root.add_child(content_row)
      
      // Sidebar: 30% width
      let sidebar = @wrapper.NodeBuilder::column()
        .width_percent(30.0)
        .height_percent(100.0)
        .build()
      sidebar_yoga.val = Some(sidebar)
      content_row.add_child(sidebar)
      
      // Main area: Flex grow
      let main = @wrapper.NodeBuilder::column()
        .flex_grow(1.0)
        .height_percent(100.0)
        .padding(1.0)
        .build()
      main_yoga.val = Some(main)
      content_row.add_child(main)
      
      // Footer: Fixed height
      let footer = @wrapper.NodeBuilder::new()
        .height(3.0)
        .width_percent(100.0)
        .build()
      footer_yoga.val = Some(footer)
      root.add_child(footer)
    })
    .on_init(fn(_app) {
      // Create components after layout is set up
      
      // Header box component
      header_box.val = Some(
        @components.Box::new("header")
          .with_border_style(BorderStyle::Double)
          .with_border_color(RGBA::cyan())
          .with_title("OneBit-TUI: Components + Yoga")
      )
      
      // Menu list component
      let menu_items : Array[@components.ListItem] = [
        { id: "1", text: "File Operations", icon: Some("📁"), data: None },
        { id: "2", text: "Edit Options", icon: Some("✏️"), data: None },
        { id: "3", text: "View Settings", icon: Some("👁"), data: None },
        { id: "4", text: "Run Commands", icon: Some("▶️"), data: None },
        { id: "5", text: "Debug Tools", icon: Some("🐛"), data: None },
      ]
      
      menu_list.val = Some(
        @components.List::new("menu", menu_items)
          .with_border_style(BorderStyle::Single)
          .with_border_color(RGBA::blue())
          .with_title("Menu")
      )
      
      // Select component for main area
      select_component.val = Some(
        @components.Select::new([
          @components.SelectItem::new("Yoga handles all layout calculations", "1", false),
          @components.SelectItem::new("Components just render at calculated positions", "2", false),
          @components.SelectItem::new("Flexible, responsive layouts are easy", "3", false),
          @components.SelectItem::new("No manual position calculations needed", "4", false),
        ])
          .with_border_style(BorderStyle::Rounded)
          .with_border_color(RGBA::green())
          .with_title("Benefits of Yoga Layout")
      )
      
      // Info text
      info_text.val = Some(
        @components.Text::new("info", "Use arrow keys to navigate • Enter to select • Q to quit")
          .with_align(TextAlign::Center)
          .with_foreground_color(RGBA::yellow())
      )
    })
    .on_key(Key::ArrowUp, fn() {
      match menu_list.val {
        Some(list) => list.select_previous()
        None => ()
      }
    })
    .on_key(Key::ArrowDown, fn() {
      match menu_list.val {
        Some(list) => list.select_next()
        None => ()
      }
    })
    .on_key(Key::Tab, fn() {
      // Toggle focus between menu and select
      match (menu_list.val, select_component.val) {
        (Some(list), Some(select)) => {
          if list.focused {
            list.focused = false
            select.focused = true
          } else {
            list.focused = true
            select.focused = false
          }
        }
        _ => ()
      }
    })
    .on_update(fn(app, buffer) {
      // Update component positions based on Yoga layout
      
      // Header
      match (header_yoga.val, header_box.val) {
        (Some(yoga), Some(box)) => {
          let layout = yoga.get_layout()
          box.set_bounds(
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int()
          )
          box.render(buffer)
          
          // Add some text inside header
          buffer.write_string(
            layout.left.to_int() + 3,
            layout.top.to_int() + 2,
            "✨ Components automatically positioned by Yoga flexbox",
            RGBA::white(),
            RGBA::transparent(),
            TextStyle::Bold
          )
          
          buffer.write_string(
            layout.left.to_int() + 3,
            layout.top.to_int() + 4,
            "Frame: \{app.get_frame_count()} | FPS: \{app.fps}",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
        }
        _ => ()
      }
      
      // Sidebar with List
      match (sidebar_yoga.val, menu_list.val) {
        (Some(yoga), Some(list)) => {
          let layout = yoga.get_layout()
          list.set_bounds(
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int()
          )
          list.render(buffer)
        }
        _ => ()
      }
      
      // Main area with Select
      match (main_yoga.val, select_component.val) {
        (Some(yoga), Some(select)) => {
          let layout = yoga.get_layout()
          select.set_bounds(
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int() / 2  // Take half the height
          )
          select.render(buffer)
          
          // Show layout info below
          let info_y = layout.top.to_int() + layout.height.to_int() / 2 + 2
          buffer.write_string(
            layout.left.to_int() + 2,
            info_y,
            "Layout Info:",
            RGBA::cyan(),
            RGBA::transparent(),
            TextStyle::Bold
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            info_y + 1,
            "• Main area uses flex-grow to fill available space",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            info_y + 2,
            "• Sidebar has 30% width, main area takes the rest",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
          
          buffer.write_string(
            layout.left.to_int() + 2,
            info_y + 3,
            "• Gaps and padding handled automatically by Yoga",
            RGBA::gray(),
            RGBA::transparent(),
            TextStyle::None
          )
        }
        _ => ()
      }
      
      // Footer
      match (footer_yoga.val, info_text.val) {
        (Some(yoga), Some(text)) => {
          let layout = yoga.get_layout()
          
          // Draw footer border
          draw_simple_border(
            buffer,
            layout.left.to_int(),
            layout.top.to_int(),
            layout.width.to_int(),
            layout.height.to_int(),
            RGBA::magenta()
          )
          
          // Position text in footer
          text.set_bounds(
            layout.left.to_int() + 1,
            layout.top.to_int() + 1,
            layout.width.to_int() - 2,
            1
          )
          text.render(buffer)
        }
        _ => ()
      }
    })
    .run()
}

// Simple border drawing helper
fn draw_simple_border(
  buffer : @ffi.TextBuffer,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  color : RGBA
) -> Unit {
  // Top and bottom
  for i = 0; i < width; i = i + 1 {
    buffer.write_string(x + i, y, "─", color, RGBA::transparent(), TextStyle::None)
    buffer.write_string(x + i, y + height - 1, "─", color, RGBA::transparent(), TextStyle::None)
  }
  
  // Sides
  for i = 0; i < height; i = i + 1 {
    buffer.write_string(x, y + i, "│", color, RGBA::transparent(), TextStyle::None)
    buffer.write_string(x + width - 1, y + i, "│", color, RGBA::transparent(), TextStyle::None)
  }
  
  // Corners
  buffer.write_string(x, y, "┌", color, RGBA::transparent(), TextStyle::None)
  buffer.write_string(x + width - 1, y, "┐", color, RGBA::transparent(), TextStyle::None)
  buffer.write_string(x, y + height - 1, "└", color, RGBA::transparent(), TextStyle::None)
  buffer.write_string(x + width - 1, y + height - 1, "┘", color, RGBA::transparent(), TextStyle::None)
}