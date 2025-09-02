///| Demo showcasing BaseRenderable architecture with Yoga layout integration
///| This demonstrates that ANY component can contain ANY other component

fn main() -> Unit {
  // Initialize terminal
  let terminal = @ffi.get_terminal()
  terminal.clear()
  terminal.hide_cursor()
  
  let (width, height) = terminal.get_size()
  
  // Create buffer
  let buffer = @core.Buffer::new(width, height)
  let theme = @core.Theme::default()
  buffer.theme = theme
  
  // Create Yoga config for layout
  let yoga_config = @yoga.Config::new()
  yoga_config.set_use_web_defaults(true)
  
  // Create root container with Yoga layout
  let root = @yoga.Node::new_with_config(yoga_config)
  root.set_width(width.to_float())
  root.set_height(height.to_float())
  root.set_flex_direction(@yoga.FlexDirection::Column)
  root.set_padding(@yoga.Edge::All, 2.0)
  
  // Create components demonstrating composition
  
  // 1. Text inside Box
  let header_box = @components.Box::new("header-box")
    .with_border_style(@core.BorderStyle::Double)
    .with_border_color(@core.Color::cyan())
    .with_title("OpenTUI + Yoga Demo")
    .with_padding(1)
  
  let header_text = @components.Text::new("header-text", "Demonstrating BaseRenderable Architecture")
    .with_align(@core.TextAlign::Center)
    .with_style(@core.TextStyle::Bold)
    .with_foreground_color(@core.Color::yellow())
  
  // Text is a child of Box!
  header_box.add_child(header_text.as_renderable())
  
  // 2. Box inside Box (nested boxes)
  let outer_box = @components.Box::new("outer-box")
    .with_border_style(@core.BorderStyle::Single)
    .with_border_color(@core.Color::blue())
    .with_title("Outer Box")
  
  let inner_box = @components.Box::new("inner-box")
    .with_border_style(@core.BorderStyle::Rounded)
    .with_border_color(@core.Color::green())
    .with_title("Inner Box")
    .with_padding(1)
  
  let inner_text = @components.Text::new("inner-text", "I'm inside two boxes!")
    .with_foreground_color(@core.Color::magenta())
  
  // Compose: Text -> Inner Box -> Outer Box
  inner_box.add_child(inner_text.as_renderable())
  outer_box.add_child(inner_box.as_renderable())
  
  // 3. Group with mixed components
  let content_group = @components.Group::new("content-group")
  
  let item1 = @components.Text::new("item1", "• Any component can contain any component")
    .with_foreground_color(@core.Color::white())
  
  let item2 = @components.Text::new("item2", "• Components are composed via BaseRenderable")
    .with_foreground_color(@core.Color::white())
  
  let item3 = @components.Text::new("item3", "• Layout is handled by Yoga")
    .with_foreground_color(@core.Color::white())
  
  content_group.add_child(item1.as_renderable())
  content_group.add_child(item2.as_renderable())
  content_group.add_child(item3.as_renderable())
  
  // 4. Using layout helpers
  let button_group = @helpers.hstack([
    create_button("OK", @core.Color::green()),
    @helpers.spacer(2, 1).as_renderable(),
    create_button("Cancel", @core.Color::red()),
  ])
  
  // 5. Complex composition - Select inside a Box with Text
  let select_box = @components.Box::new("select-box")
    .with_border_style(@core.BorderStyle::Single)
    .with_title("Selection")
  
  let select_label = @components.Text::new("select-label", "Choose an option:")
  
  let select = @components.Select::new([
    @components.SelectItem::new("Option 1", "opt1", false),
    @components.SelectItem::new("Option 2", "opt2", false),
    @components.SelectItem::new("Option 3", "opt3", false),
  ])
  
  select_box.add_child(select_label.as_renderable())
  select_box.add_child(select.as_renderable())
  
  // Create Yoga nodes for layout
  let header_yoga = @yoga.Node::new()
  header_yoga.set_height(5.0)
  header_yoga.set_margin(@yoga.Edge::Bottom, 1.0)
  
  let nested_yoga = @yoga.Node::new()
  nested_yoga.set_flex_grow(1.0)
  nested_yoga.set_flex_direction(@yoga.FlexDirection::Row)
  nested_yoga.set_margin(@yoga.Edge::Bottom, 1.0)
  
  let outer_yoga = @yoga.Node::new()
  outer_yoga.set_flex(1.0)
  outer_yoga.set_margin(@yoga.Edge::Right, 2.0)
  
  let content_yoga = @yoga.Node::new()
  content_yoga.set_flex(1.0)
  
  let select_yoga = @yoga.Node::new()
  select_yoga.set_height(8.0)
  select_yoga.set_margin(@yoga.Edge::Bottom, 1.0)
  
  let button_yoga = @yoga.Node::new()
  button_yoga.set_height(3.0)
  button_yoga.set_align_self(@yoga.Align::Center)
  
  // Build Yoga tree
  root.add_child(header_yoga)
  root.add_child(nested_yoga)
  nested_yoga.add_child(outer_yoga)
  nested_yoga.add_child(content_yoga)
  root.add_child(select_yoga)
  root.add_child(button_yoga)
  
  // Calculate layout
  root.calculate_layout(width.to_float(), height.to_float(), @yoga.Direction::LTR)
  
  // Apply Yoga layout to components
  apply_yoga_layout(header_box.base, header_yoga)
  apply_yoga_layout(outer_box.base, outer_yoga)
  apply_yoga_layout(content_group.base, content_yoga)
  apply_yoga_layout(select_box.base, select_yoga)
  apply_yoga_layout(button_group.base, button_yoga)
  
  // Create root renderable
  let root_group = @components.Group::new("root")
  root_group.add_child(header_box.as_renderable())
  root_group.add_child(outer_box.as_renderable())
  root_group.add_child(content_group.as_renderable())
  root_group.add_child(select_box.as_renderable())
  root_group.add_child(button_group.as_renderable())
  
  // Main render loop
  let mut running = true
  
  while running {
    buffer.clear(@core.Color::rgb(10, 10, 20))
    
    // Render the entire tree
    root_group.as_renderable().render(buffer)
    
    // Status bar
    let status = "Press 'q' to quit | BaseRenderable + Yoga Layout Demo"
    buffer.write_string(
      width / 2 - status.length() / 2,
      height - 1,
      status,
      @core.Color::white(),
      @core.Color::rgb(30, 30, 40)
    )
    
    // Render to terminal
    terminal.render_buffer(buffer)
    
    // Handle input
    match terminal.read_key() {
      Some(key) => {
        match key {
          "q" | "Q" => running = false
          _ => ()
        }
      }
      None => ()
    }
    
    terminal.sleep(16) // ~60 FPS
  }
  
  // Cleanup
  terminal.show_cursor()
  terminal.clear()
}

// Helper to create a button-like component
fn create_button(label : String, color : @core.Color) -> @core.BaseRenderable {
  let button_box = @components.Box::new("button-\{label}")
    .with_border_style(@core.BorderStyle::Single)
    .with_border_color(color)
    .with_padding(0)
  
  let button_text = @components.Text::new("button-text-\{label}", label)
    .with_align(@core.TextAlign::Center)
    .with_foreground_color(color)
  
  button_box.add_child(button_text.as_renderable())
  button_box.base.width = label.length() + 4
  button_box.base.height = 3
  
  button_box.as_renderable()
}

// Apply Yoga layout results to BaseRenderable
fn apply_yoga_layout(renderable : @core.BaseRenderable, yoga_node : @yoga.Node) -> Unit {
  let layout = yoga_node.get_layout()
  renderable.x = layout.left.to_int()
  renderable.y = layout.top.to_int()
  renderable.width = layout.width.to_int()
  renderable.height = layout.height.to_int()
  
  // Apply to children if they have corresponding Yoga nodes
  for i = 0; i < renderable.children.length(); i = i + 1 {
    if i < yoga_node.get_child_count() {
      let child_yoga = yoga_node.get_child(i)
      match child_yoga {
        Some(child_node) => apply_yoga_layout(renderable.children[i], child_node)
        None => ()
      }
    }
  }
}