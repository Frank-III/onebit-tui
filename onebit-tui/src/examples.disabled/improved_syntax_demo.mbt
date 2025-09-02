///| Demo showing improved layout syntax

fn main {
  // Initialize
  let term = @ffi.init_terminal()
  defer @ffi.restore_terminal(term)
  
  let mut buffer = @core.TerminalBuffer::new(80, 24)
  
  // OLD WAY - verbose and imperative
  let old_way = @components.SimpleBox::new("container")
  old_way.bounds = @core.Rect::new(0, 0, 40, 12)
  old_way.border_style = @core.BorderStyle::Single
  old_way.title = Some("Old Way")
  
  let child1 = @components.SimpleBox::new("child1") 
  child1.bounds = @core.Rect::new(2, 2, 36, 4)
  child1.background_color = @core.RGBA::{ r: 0.2, g: 0.2, b: 0.2, a: 1.0 }
  old_way.children.push(child1)
  
  let child2 = @components.SimpleBox::new("child2")
  child2.bounds = @core.Rect::new(2, 7, 36, 3)
  child2.background_color = @core.RGBA::{ r: 0.1, g: 0.1, b: 0.3, a: 1.0 }
  old_way.children.push(child2)
  
  // NEW WAY - declarative and chainable
  let new_way = @components.SimpleBox::new("container")
    .with_bounds(41, 0, 39, 12)
    .with_border(@core.BorderStyle::Double)
    .with_title("New Way")
    .with_children([
      @components.SimpleBox::new("child1")
        .with_bounds(2, 2, 35, 4)
        .with_colors(
          @core.RGBA::{ r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
          @core.RGBA::{ r: 0.2, g: 0.2, b: 0.2, a: 1.0 }
        ),
      @components.SimpleBox::new("child2")  
        .with_bounds(2, 7, 35, 3)
        .with_colors(
          @core.RGBA::{ r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
          @core.RGBA::{ r: 0.1, g: 0.1, b: 0.3, a: 1.0 }
        )
    ])
  
  // Even more concise with helper functions
  let concise = @components.padding("wrapper", 1,
    @components.column("content", [
      @components.SimpleBox::new("header")
        .with_title("Header")
        .with_border(@core.BorderStyle::Single),
      @components.SimpleBox::new("body")
        .with_title("Content") 
        .with_border(@core.BorderStyle::Rounded),
      @components.SimpleBox::new("footer")
        .with_title("Footer")
        .with_border(@core.BorderStyle::Single)
    ])
  ).with_bounds(0, 13, 80, 11)
    .with_border(@core.BorderStyle::Thick)
    .with_title("Concise Syntax")
  
  // Clear and render
  buffer.clear()
  
  // Render all examples
  old_way.render_box(buffer)
  new_way.render_box(buffer) 
  concise.render_box(buffer)
  
  buffer.render()
  
  // Event loop
  while true {
    match @ffi.read_key() {
      @core.KeyEvent::Char('q') => break
      _ => continue
    }
  }
}

// Example showing how the new syntax would work with real layouts
fn create_app_layout() -> @components.SimpleBox {
  @components.column("app", [
    // Header
    @components.row("header", [
      @components.SimpleBox::new("logo").with_title("MyApp"),
      @components.SimpleBox::new("menu").with_title("File Edit View"),
      @components.SimpleBox::new("user").with_title("User")
    ]).with_border(@core.BorderStyle::Single),
    
    // Main area with sidebar
    @components.row("main", [
      @components.column("sidebar", [
        @components.SimpleBox::new("nav").with_title("Navigation"),
        @components.SimpleBox::new("tools").with_title("Tools")
      ]).with_border(@core.BorderStyle::Single),
      
      @components.padding("content-area", 2,
        @components.SimpleBox::new("editor")
          .with_title("main.mbt")
          .with_border(@core.BorderStyle::Rounded)
      )
    ]),
    
    // Status bar
    @components.SimpleBox::new("status")
      .with_title("Ready | Line 1, Col 1")
      .with_border(@core.BorderStyle::Single)
  ])
}

// The goal: Make TUI layout code as declarative as web UI frameworks!