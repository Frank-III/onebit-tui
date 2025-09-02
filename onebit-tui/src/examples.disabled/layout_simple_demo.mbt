///| Simple demo of the improved layout syntax

fn main {
  // Example 1: Simple horizontal layout
  let example1 = @components.hstack("example1", [
    @components.LayoutBox::new("left").with_width(20.0),
    @components.LayoutBox::new("center").with_flex(1.0),
    @components.LayoutBox::new("right").with_width(20.0)
  ])
  
  // Example 2: Nested layout with padding
  let example2 = @components.padding("outer", 2.0,
    @components.vstack("inner", [
      @components.LayoutBox::new("header").with_height(3.0),
      @components.spacer("space"),
      @components.LayoutBox::new("footer").with_height(3.0)
    ])
  )
  
  // Example 3: Centered content
  let example3 = @components.centered("center-demo",
    @components.fixed_box("box", 30.0, 10.0)
      .with_title("Centered!")
      .with_border(@core.BorderStyle::Rounded)
  )
  
  // Example 4: Complex app layout in just a few lines
  let app = @components.vstack("app", [
    // Top bar
    @components.hstack("topbar", [
      @components.LayoutBox::new("logo").with_width(10.0),
      @components.spacer("topbar-space"),
      @components.LayoutBox::new("user").with_width(20.0)
    ]).with_height(3.0)
      .with_border(@core.BorderStyle::Single),
    
    // Main content with sidebar
    @components.hstack("main", [
      // Sidebar
      @components.vstack("sidebar", [
        @components.LayoutBox::new("nav")
          .with_title("Navigation")
          .with_flex(1.0),
        @components.LayoutBox::new("tools")
          .with_title("Tools")
          .with_height(10.0)
      ]).with_width(25.0)
        .with_padding(1.0),
      
      // Content area
      @components.padding("content-wrapper", 2.0,
        @components.LayoutBox::new("content")
          .with_title("Main Content")
          .with_border(@core.BorderStyle::Rounded)
      ).with_flex(1.0)
    ]).with_flex(1.0),
    
    // Status bar
    @components.LayoutBox::new("status")
      .with_height(1.0)
      .with_title("Ready")
  ])
  
  // The entire layout is declarative and easy to read!
  println("Layout created successfully")
}