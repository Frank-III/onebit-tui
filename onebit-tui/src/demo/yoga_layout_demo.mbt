///| Yoga Layout Demo
///| Demonstrates the Yoga-based layout system with Views

pub fn run_yoga_layout_demo() -> Unit {
  println("=== Yoga Layout Demo ===")
  
  match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(app) => {
      app.run_once(fn(app) {
        // Create a root container with column layout
        let root = @components.View::new()
          .flex_direction(@components.FlexDirection::Column)
          .padding(2.0)
          .background(@core.Color::DarkBlue)
          .width(@components.SizeValue::Percent(100.0))
          .height(@components.SizeValue::Percent(100.0))
        
        // Header with centered title
        let header = @components.View::new()
          .flex_direction(@components.FlexDirection::Row)
          .justify_content(@components.Justify::Center)
          .align_items(@components.Align::Center)
          .height(@components.SizeValue::Points(3.0))
          .background(@core.Color::Blue)
          .border(@components.BorderStyle::Double, @core.Color::White)
          .add_child(
            @components.View::text("Yoga Layout System", Some(@core.Color::BrightWhite))
          )
        
        // Main content area with two columns
        let main_content = @components.View::new()
          .flex_direction(@components.FlexDirection::Row)
          .flex(1.0)  // Take remaining space
          .padding(1.0)
        
        // Left panel
        let left_panel = @components.View::new()
          .flex_direction(@components.FlexDirection::Column)
          .flex(1.0)
          .margin(1.0)
          .padding(2.0)
          .background(@core.Color::DarkGreen)
          .border(@components.BorderStyle::Single, @core.Color::Green)
          .add_child(
            @components.View::text("Left Panel", Some(@core.Color::BrightGreen))
          )
          .add_child(
            @components.View::new()
              .margin(1.0)
              .add_child(
                @components.View::text("• Flex: 1", Some(@core.Color::White))
              )
          )
          .add_child(
            @components.View::text("• Takes 50% width", Some(@core.Color::White))
          )
          .add_child(
            @components.View::text("• Column layout", Some(@core.Color::White))
          )
        
        // Right panel with nested boxes
        let right_panel = @components.View::new()
          .flex_direction(@components.FlexDirection::Column)
          .flex(1.0)
          .margin(1.0)
          .padding(2.0)
          .background(@core.Color::DarkMagenta)
          .border(@components.BorderStyle::Single, @core.Color::Magenta)
        
        // Add nested boxes to right panel
        let box1 = @components.View::new()
          .padding(1.0)
          .margin(1.0)
          .background(@core.Color::DarkCyan)
          .border(@components.BorderStyle::Rounded, @core.Color::Cyan)
          .add_child(
            @components.View::text("Nested Box 1", Some(@core.Color::BrightCyan))
          )
        
        let box2 = @components.View::new()
          .padding(1.0)
          .margin(1.0)
          .background(@core.Color::DarkYellow)
          .border(@components.BorderStyle::Rounded, @core.Color::Yellow)
          .add_child(
            @components.View::text("Nested Box 2", Some(@core.Color::BrightYellow))
          )
        
        right_panel
          .add_child(@components.View::text("Right Panel", Some(@core.Color::BrightMagenta)))
          .add_child(box1)
          .add_child(box2)
        
        // Add panels to main content
        main_content
          .add_child(left_panel)
          .add_child(right_panel)
        
        // Footer with status bar
        let footer = @components.View::new()
          .flex_direction(@components.FlexDirection::Row)
          .justify_content(@components.Justify::SpaceBetween)
          .height(@components.SizeValue::Points(3.0))
          .padding(1.0)
          .background(@core.Color::DarkGray)
          .border(@components.BorderStyle::Single, @core.Color::Gray)
          .add_child(
            @components.View::text("Press 'q' to quit", Some(@core.Color::White))
          )
          .add_child(
            @components.View::text("Yoga Layout v1.0", Some(@core.Color::BrightBlue))
          )
        
        // Build the complete layout tree
        root
          .add_child(header)
          .add_child(main_content)
          .add_child(footer)
        
        // Calculate layout for the entire tree
        let width = app.width.to_double()
        let height = app.height.to_double()
        root.calculate_layout(width, height)
        
        // Render the tree
        root.render(app, 0, 0)
        
        // Debug info - show computed layouts
        show_debug_info(app, root, 70, 2)
      })
      
      // Wait for user input
      @ffi.sleep_ms(10000)
      app.cleanup()
      println("Demo complete!")
    }
  }
}

// Helper to show debug info about computed layouts
fn show_debug_info(app : @core.App, view : @components.View, x : Int, y : Int) -> Unit {
  app.draw_text("=== Debug Info ===", x, y, @core.Color::White)
  
  match view.computed {
    Some(layout) => {
      app.draw_text("Root Layout:", x, y + 2, @core.Color::Gray)
      app.draw_text("x: \{layout.x}", x, y + 3, @core.Color::Gray)
      app.draw_text("y: \{layout.y}", x, y + 4, @core.Color::Gray)
      app.draw_text("w: \{layout.width}", x, y + 5, @core.Color::Gray)
      app.draw_text("h: \{layout.height}", x, y + 6, @core.Color::Gray)
      
      app.draw_text("Children: \{view.children.length()}", x, y + 8, @core.Color::Gray)
    }
    None => {
      app.draw_text("No layout computed", x, y + 2, @core.Color::Red)
    }
  }
}

// Alternative API design - more declarative
pub fn create_ui_declarative() -> @components.View {
  // This shows a more React-like API
  @components.View::new()
    .flex_direction(@components.FlexDirection::Column)
    .children([
      // Header
      @components.View::new()
        .height(@components.SizeValue::Points(3.0))
        .background(@core.Color::Blue)
        .justify_content(@components.Justify::Center)
        .add_child(@components.View::text("Title", None)),
      
      // Body
      @components.View::new()
        .flex(1.0)
        .flex_direction(@components.FlexDirection::Row)
        .children([
          // Sidebar
          @components.View::new()
            .width(@components.SizeValue::Points(20.0))
            .background(@core.Color::DarkGray),
          
          // Content
          @components.View::new()
            .flex(1.0)
            .padding(2.0)
        ]),
      
      // Footer
      @components.View::new()
        .height(@components.SizeValue::Points(1.0))
        .background(@core.Color::Gray)
    ])
}

// Helper to add multiple children at once
fn View::children(self : @components.View, children : Array[@components.View]) -> @components.View {
  for i = 0; i < children.length(); i = i + 1 {
    self.add_child(children[i])
  }
  self
}