///| Demo showcasing BaseRenderable architecture - Updated with App wrapper
///| This demonstrates that ANY component can contain ANY other component


fn main() -> Unit {
  // Create components
  let header_box = Ref::new(@components.Box::new("header-box"))
  let outer_box = Ref::new(@components.Box::new("outer-box"))
  let inner_box = Ref::new(@components.Box::new("inner-box"))
  let inner_text = Ref::new(@components.Text::new("inner-text", ""))
  let features_group = Ref::new(@components.Group::new("features-group"))
  let unusual_box = Ref::new(@components.Box::new("unusual-box"))
  let select = Ref::new(@components.Select::new([]))
  let root = Ref::new(@components.Group::new("root"))
  let frame_count = Ref::new(0)
  
  App::new()
    .title("BaseRenderable Architecture Demo")
    .size(100, 40)
    .background(RGBA::new(0.04, 0.04, 0.08, 1.0))
    .on_init(fn(app) {
      let width = app.width
      let height = app.height
      
      // 1. Text inside Box - most common pattern
      header_box.val = @components.Box::new("header-box")
        .with_border_style(BorderStyle::Double)
        .with_border_color(RGBA::cyan())
        .with_title("BaseRenderable Architecture Demo")
        .with_padding(1)
        .with_dimensions(2, 1, width - 4, 5)
      
      let header_text = @components.Text::new("header-text", "ANY component can contain ANY other component!")
        .with_align(TextAlign::Center)
        .with_style(TextStyle::Bold)
        .with_foreground_color(RGBA::yellow())
        .with_dimensions(0, 0, header_box.val.base.width - 4, 1)
      
      // Text is a child of Box!
      header_box.val.add_child(header_text.as_renderable())
      
      // 2. Box inside Box (nested boxes)
      outer_box.val = @components.Box::new("outer-box")
        .with_border_style(BorderStyle::Single)
        .with_border_color(RGBA::blue())
        .with_title("Outer Box")
        .with_dimensions(2, 7, width / 2 - 2, 12)
      
      inner_box.val = @components.Box::new("inner-box")
        .with_border_style(BorderStyle::Rounded)
        .with_border_color(RGBA::green())
        .with_title("Inner Box")
        .with_padding(1)
        .with_dimensions(2, 2, outer_box.val.base.width - 6, 8)
      
      inner_text.val = @components.Text::new("inner-text", "I'm text inside two nested boxes! This proves that components can be freely composed.")
        .with_foreground_color(RGBA::magenta())
        .with_wrap(TextWrap::Word)
        .with_dimensions(0, 0, inner_box.val.base.width - 4, 6)
      
      // Compose: Text -> Inner Box -> Outer Box
      inner_box.val.add_child(inner_text.val.as_renderable())
      outer_box.val.add_child(inner_box.val.as_renderable())
      
      // 3. Group with mixed components
      features_group.val = @components.Group::new("features-group")
        .with_dimensions(width / 2 + 1, 7, width / 2 - 3, 12)
      
      let features_box = @components.Box::new("features-box")
        .with_border_style(BorderStyle::Single)
        .with_title("Key Features")
        .with_dimensions(0, 0, features_group.val.base.width, features_group.val.base.height)
      
      let feature1 = @components.Text::new("feature1", "✓ Components use BaseRenderable")
        .with_foreground_color(RGBA::green())
        .with_dimensions(2, 2, features_box.base.width - 4, 1)
      
      let feature2 = @components.Text::new("feature2", "✓ Any component can contain any component")
        .with_foreground_color(RGBA::green())
        .with_dimensions(2, 3, features_box.base.width - 4, 1)
      
      let feature3 = @components.Text::new("feature3", "✓ Components set their own render function")
        .with_foreground_color(RGBA::green())
        .with_dimensions(2, 4, features_box.base.width - 4, 1)
      
      let feature4 = @components.Text::new("feature4", "✓ Clean API with App wrapper and Key enum")
        .with_foreground_color(RGBA::green())
        .with_dimensions(2, 5, features_box.base.width - 4, 1)
      
      // Add features to the box
      features_box.add_child(feature1.as_renderable())
      features_box.add_child(feature2.as_renderable())
      features_box.add_child(feature3.as_renderable())
      features_box.add_child(feature4.as_renderable())
      
      // Box goes in the group
      features_group.val.add_child(features_box.as_renderable())
      
      // 4. Complex composition - even unusual combinations work!
      unusual_box.val = @components.Box::new("unusual-box")
        .with_border_style(BorderStyle::Dashed)
        .with_title("Unusual: Box containing Select!")
        .with_dimensions(2, 20, width - 4, 8)
      
      // Yes, even a Select can be inside a Box!
      select.val = @components.Select::new([
        @components.SelectItem::new("BaseRenderable is flexible", "opt1", false),
        @components.SelectItem::new("Components compose freely", "opt2", false),
        @components.SelectItem::new("No special parent-child rules", "opt3", false),
      ])
      select.val.set_position(2, 2)
      select.val.set_size(unusual_box.val.base.width - 6, 4)
      
      unusual_box.val.add_child(select.val.as_renderable())
      
      // Create root group to hold everything
      root.val = @components.Group::new("root")
      root.val.add_child(header_box.val.as_renderable())
      root.val.add_child(outer_box.val.as_renderable())
      root.val.add_child(features_group.val.as_renderable())
      root.val.add_child(unusual_box.val.as_renderable())
    })
    .on_key(Key::ArrowUp, fn() {
      select.val.select_previous()
    })
    .on_key(Key::ArrowDown, fn() {
      select.val.select_next()
    })
    .on_key(Key::Enter, fn() {
      select.val.trigger_select()
    })
    .on_update(fn(app, buffer) {
      // Animation: update inner text color
      let color = if frame_count.val % 60 < 30 {
        RGBA::magenta()
      } else {
        RGBA::cyan()
      }
      inner_text.val.base.foreground_color = color
      
      // Render the entire component tree
      root.val.as_renderable().render(buffer)
      
      // Status bar
      buffer.write_string(
        2, app.height - 1,
        "Use ↑↓ to navigate, Enter to select, Q/ESC to quit | Frame: \{frame_count.val}",
        RGBA::white(),
        RGBA::new(0.12, 0.12, 0.16, 1.0),
        TextStyle::None
      )
      
      frame_count.val = frame_count.val + 1
    })
    .run()
}