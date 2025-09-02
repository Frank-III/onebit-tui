///| Demo showing the proper component architecture
///| Where ANY component can contain ANY other component

fn main {
  let term = @ffi.init_terminal()
  defer @ffi.restore_terminal(term)
  
  let mut buffer = @core.TerminalBuffer::new(80, 24)
  
  // Create a complex UI showing that any component can contain any other
  let app = @components.vstack("app", [
    // Header with nested components
    @components.Box::new("header")
      .with_size(80, 5)
      .with_border(@core.BorderStyle::Double)
      .with_title("Application Header")
      .with_background(@core.RGBA::{ r: 0.1, g: 0.2, b: 0.4, a: 1.0 })
      .add(
        @components.hstack("header-content", [
          @components.text("Logo").with_color(@core.RGBA::{ r: 1.0, g: 0.8, b: 0.0, a: 1.0 }),
          @components.Group::new("spacer").with_flex(1.0),
          @components.text("User: admin")
        ])
      ),
    
    // Main body with mixed components
    @components.hstack("body", [
      // Sidebar with text items inside a box
      @components.Box::new("sidebar")
        .with_size(20, 14)
        .with_border(@core.BorderStyle::Single)
        .with_title("Navigation")
        .add(
          @components.vstack("nav-items", [
            @components.text("Dashboard"),
            @components.text("Settings"),
            @components.text("Profile"),
            // A box inside the sidebar containing more text
            @components.Box::new("submenu")
              .with_border(@core.BorderStyle::Rounded)
              .with_padding(1)
              .add(
                @components.vstack("submenu-items", [
                  @components.text("Option 1"),
                  @components.text("Option 2")
                ])
              )
          ])
        ),
      
      // Main content area - Group containing mixed components
      @components.Group::new("content")
        .with_flex(1.0)
        .with_children([
          // Text directly in a group
          @components.text("Welcome to the application!").with_style(@core.TextStyle::Bold),
          
          // Box with complex nested structure
          @components.Box::new("data-view")
            .with_border(@core.BorderStyle::Thick)
            .with_title("Data")
            .add(
              @components.hstack("data-row", [
                @components.text("Status: "),
                @components.colored_text("Active", @core.RGBA::{ r: 0.0, g: 1.0, b: 0.0, a: 1.0 })
              ])
            ),
          
          // Another text element
          @components.text("More content here...")
        ])
    ]).with_flex(1.0),
    
    // Footer - Box containing a Group containing Text
    @components.Box::new("footer")
      .with_size(80, 3)
      .with_border(@core.BorderStyle::Single)
      .with_background(@core.RGBA::{ r: 0.2, g: 0.2, b: 0.2, a: 1.0 })
      .add(
        @components.center("footer-content",
          @components.text("Press 'q' to quit | F1 for help")
        )
      )
  ])
  
  // Render the entire UI tree
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

// This demonstrates the key insight:
// - Box is NOT the only container - it's just one type of component
// - Group is an invisible container
// - Text can exist inside Box, Group, or any other component
// - ANY component can contain ANY other component
// - The component tree is completely flexible