///| Demo showcasing the improved layout syntax

fn main {
  // Initialize terminal
  let term = @ffi.init_terminal()
  defer @ffi.restore_terminal(term)
  
  let mut buffer = @core.TerminalBuffer::new(80, 24)
  
  // Create layout using the new syntax
  let app = @components.hstack("app", [
    // Sidebar
    @components.vstack("sidebar", [
      @components.fixed_box("logo", 20.0, 3.0)
        .with_title("Logo")
        .with_border(@core.BorderStyle::Double),
      
      @components.LayoutBox::new("menu")
        .with_title("Menu")
        .with_border(@core.BorderStyle::Single)
        .with_flex(1.0),
      
      @components.fixed_box("status", 20.0, 3.0)
        .with_title("Status")
        .with_border(@core.BorderStyle::Single)
    ]).with_width(22.0)
      .with_padding(1.0),
    
    // Main content area
    @components.vstack("content", [
      // Header
      @components.LayoutBox::row_with("header", [
        @components.LayoutBox::new("title")
          .with_title("Header")
          .with_flex(1.0),
        
        @components.fixed_box("user", 15.0, 3.0)
          .with_title("User")
      ]).with_height(3.0)
        .with_border(@core.BorderStyle::Single),
      
      // Body with centered content
      @components.centered("body", 
        @components.padding("inner", 2.0,
          @components.LayoutBox::new("message")
            .with_title("Hello, Flexbox!")
            .with_width(40.0)
            .with_height(10.0)
            .with_border(@core.BorderStyle::Rounded)
        )
      ).with_flex(1.0),
      
      // Footer
      @components.LayoutBox::row_with("footer", [
        @components.spacer("left-space"),
        @components.LayoutBox::new("help")
          .with_title("Press 'q' to quit")
          .with_padding(1.0),
        @components.spacer("right-space")
      ]).with_height(3.0)
        .with_border(@core.BorderStyle::Single)
    ]).with_flex(1.0)
  ])
  
  // Calculate layout
  app.calculate_layout(80.0, 24.0)
  
  // Render
  buffer.clear()
  app.render(buffer)
  buffer.render()
  
  // Event loop
  while true {
    match @ffi.read_key() {
      @core.KeyEvent::Char('q') => break
      _ => continue
    }
  }
}

// Example of creating a custom component
fn create_panel(
  id : String, 
  title : String, 
  content : Array[@components.LayoutElement]
) -> @components.LayoutBox {
  @components.vstack(id, content)
    .with_title(title)
    .with_border(@core.BorderStyle::Rounded)
    .with_padding(1.0)
}

// Another example with conditional layouts
fn create_responsive_layout(is_wide : Bool) -> @components.LayoutBox {
  if is_wide {
    // Horizontal layout for wide screens
    @components.hstack("main", [
      create_panel("nav", "Navigation", [
        @components.LayoutBox::new("nav-item-1"),
        @components.LayoutBox::new("nav-item-2")
      ]).with_width(30.0),
      
      @components.vstack("content", [
        @components.LayoutBox::new("main-content").with_flex(1.0),
        @components.LayoutBox::new("footer").with_height(3.0)
      ]).with_flex(1.0)
    ])
  } else {
    // Vertical layout for narrow screens  
    @components.vstack("main", [
      create_panel("nav", "Navigation", [
        @components.LayoutBox::new("nav-item-1"),
        @components.LayoutBox::new("nav-item-2") 
      ]).with_height(10.0),
      
      @components.LayoutBox::new("main-content").with_flex(1.0),
      @components.LayoutBox::new("footer").with_height(3.0)
    ])
  }
}