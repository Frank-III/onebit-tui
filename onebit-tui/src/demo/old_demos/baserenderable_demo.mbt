///| Demo showcasing BaseRenderable architecture
///| This demonstrates that ANY component can contain ANY other component

fn main() -> Unit {
  // Initialize terminal
  let terminal = @ffi.get_terminal()
  terminal.clear()
  terminal.hide_cursor()
  
  let (width, height) = terminal.get_size()
  
  // Create buffer
  let buffer = Buffer::new(width, height)
  let theme = Theme::default()
  buffer.theme = theme
  
  // Create components demonstrating composition
  
  // 1. Text inside Box - most common pattern
  let header_box = @components.Box::new("header-box")
    .with_border_style(BorderStyle::Double)
    .with_border_color(Color::cyan())
    .with_title("BaseRenderable Architecture Demo")
    .with_padding(1)
    .with_dimensions(2, 1, width - 4, 5)
  
  let header_text = @components.Text::new("header-text", "ANY component can contain ANY other component!")
    .with_align(TextAlign::Center)
    .with_style(TextStyle::Bold)
    .with_foreground_color(Color::yellow())
    .with_dimensions(0, 0, header_box.base.width - 4, 1)
  
  // Text is a child of Box!
  header_box.add_child(header_text.as_renderable())
  
  // 2. Box inside Box (nested boxes)
  let outer_box = @components.Box::new("outer-box")
    .with_border_style(BorderStyle::Single)
    .with_border_color(Color::blue())
    .with_title("Outer Box")
    .with_dimensions(2, 7, width / 2 - 2, 12)
  
  let inner_box = @components.Box::new("inner-box")
    .with_border_style(BorderStyle::Rounded)
    .with_border_color(Color::green())
    .with_title("Inner Box")
    .with_padding(1)
    .with_dimensions(2, 2, outer_box.base.width - 6, 8)
  
  let inner_text = @components.Text::new("inner-text", "I'm text inside two nested boxes! This proves that components can be freely composed.")
    .with_foreground_color(Color::magenta())
    .with_wrap(TextWrap::Word)
    .with_dimensions(0, 0, inner_box.base.width - 4, 6)
  
  // Compose: Text -> Inner Box -> Outer Box
  inner_box.add_child(inner_text.as_renderable())
  outer_box.add_child(inner_box.as_renderable())
  
  // 3. Group with mixed components
  let features_group = @components.Group::new("features-group")
    .with_dimensions(width / 2 + 1, 7, width / 2 - 3, 12)
  
  let features_box = @components.Box::new("features-box")
    .with_border_style(BorderStyle::Single)
    .with_title("Key Features")
    .with_dimensions(0, 0, features_group.base.width, features_group.base.height)
  
  let feature1 = @components.Text::new("feature1", "✓ Components use BaseRenderable")
    .with_foreground_color(Color::green())
    .with_dimensions(2, 2, features_box.base.width - 4, 1)
  
  let feature2 = @components.Text::new("feature2", "✓ Any component can contain any component")
    .with_foreground_color(Color::green())
    .with_dimensions(2, 3, features_box.base.width - 4, 1)
  
  let feature3 = @components.Text::new("feature3", "✓ Components set their own render function")
    .with_foreground_color(Color::green())
    .with_dimensions(2, 4, features_box.base.width - 4, 1)
  
  let feature4 = @components.Text::new("feature4", "✓ Layout helpers create components")
    .with_foreground_color(Color::green())
    .with_dimensions(2, 5, features_box.base.width - 4, 1)
  
  // Add features to the box
  features_box.add_child(feature1.as_renderable())
  features_box.add_child(feature2.as_renderable())
  features_box.add_child(feature3.as_renderable())
  features_box.add_child(feature4.as_renderable())
  
  // Box goes in the group
  features_group.add_child(features_box.as_renderable())
  
  // 4. Complex composition - even unusual combinations work!
  let unusual_box = @components.Box::new("unusual-box")
    .with_border_style(BorderStyle::Dashed)
    .with_title("Unusual: Box containing Select!")
    .with_dimensions(2, 20, width - 4, 8)
  
  // Yes, even a Select can be inside a Box!
  let select = @components.Select::new([
    @components.SelectItem::new("BaseRenderable is flexible", "opt1", false),
    @components.SelectItem::new("Components compose freely", "opt2", false),
    @components.SelectItem::new("No special parent-child rules", "opt3", false),
  ])
  select.set_position(2, 2)
  select.set_size(unusual_box.base.width - 6, 4)
  
  unusual_box.add_child(select.as_renderable())
  
  // Create root group to hold everything
  let root = @components.Group::new("root")
  root.add_child(header_box.as_renderable())
  root.add_child(outer_box.as_renderable())
  root.add_child(features_group.as_renderable())
  root.add_child(unusual_box.as_renderable())
  
  // Main render loop
  let mut running = true
  let mut frame = 0
  
  while running {
    buffer.clear(Color::rgb(10, 10, 20))
    
    // Render the entire component tree
    root.as_renderable().render(buffer)
    
    // Animation: update inner text color
    let color = if frame % 60 < 30 {
      Color::magenta()
    } else {
      Color::cyan()
    }
    inner_text.base.foreground_color = color
    
    // Status bar
    let status = "Press 'q' to quit | Frame: \{frame}"
    buffer.write_string(
      2,
      height - 1,
      status,
      Color::white(),
      Color::rgb(30, 30, 40)
    )
    
    // Render to terminal
    terminal.render_buffer(buffer)
    
    // Handle input
    match terminal.read_key() {
      Some(key) => {
        match key {
          "q" | "Q" => running = false
          "ArrowDown" => select.handle_key(key)
          "ArrowUp" => select.handle_key(key)
          "Enter" => select.handle_key(key)
          _ => ()
        }
      }
      None => ()
    }
    
    frame += 1
    terminal.sleep(16) // ~60 FPS
  }
  
  // Cleanup
  terminal.show_cursor()
  terminal.clear()
}