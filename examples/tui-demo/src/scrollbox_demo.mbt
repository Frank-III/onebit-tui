///|
/// ScrollBox widget demo - showcases scrollable list of items (complex version - not used yet)
fn scrollbox_demo_view_complex() -> @view.View {
  // Create a list of sample items to scroll through
  let items : Array[&@view.Component] = []
  
  // Add various types of items to demonstrate scrolling
  for i = 1; i <= 50; i = i + 1 {
    if i % 5 == 0 {
      // Every 5th item is a button
      items.push(
        @widget.Button::new("Button \{i}", fn() { println("Clicked button \{i}") })
      )
    } else if i % 3 == 0 {
      // Every 3rd item is highlighted text
      items.push(
        @widget.Text::new("★ Special Item \{i} ★")
          .color(@core.Color::Cyan)
      )
    } else {
      // Regular text items
      items.push(
        @widget.Text::new("Item \{i}: Lorem ipsum dolor sit amet")
          .color(@core.Color::White)
      )
    }
  }
  
  // Create multiple scrollboxes with different configurations
  let scroll_offset1 = Ref::new(0)
  let scroll_offset2 = Ref::new(0)
  let scroll_offset3 = Ref::new(0)
  
  @view.View::container_views([
    // Title
    @view.View::text("ScrollBox Widget Demo", color=@core.Color::Cyan),
    
    @view.View::text("Use Tab to switch between boxes, arrows to scroll", color=@core.Color::Gray),
    
    // Horizontal layout with three scrollboxes
    @view.View::container_views([
      // Column 1
      @view.View::container_views([
        @widget.Text::body("Basic ScrollBox").color(@core.Color::Yellow).render(),
        @widget.ScrollBox::new(items, visible_rows=10, offset=scroll_offset1)
          .title("Items 1-50")
          .border(@view.BorderStyle::Single)
          .padding(1.0)
          .render(),
      ])
      .direction(@view.Direction::Column),
      // Column 2
      @view.View::container_views([
        @widget.Text::body("Compact ScrollBox").color(@core.Color::Yellow).render(),
        @widget.ScrollBox::new(items, visible_rows=5, offset=scroll_offset2)
          .title("Compact View")
          .border(@view.BorderStyle::Rounded)
          .padding(0.5)
          .render(),
      ])
      .direction(@view.Direction::Column),
      // Column 3
      @view.View::container_views([
        @widget.Text::body("Large ScrollBox").color(@core.Color::Yellow).render(),
        @widget.ScrollBox::new(items, visible_rows=15, offset=scroll_offset3)
          .title("Extended View")
          .border(@view.BorderStyle::Double)
          .padding(1.0)
          .render(),
      ])
      .direction(@view.Direction::Column),
    ])
      .direction(@view.Direction::Row)
      .spacing(2.0),
    
    // Instructions (use widget.Text as components)
    @widget.Text::body("Keyboard Controls:").color(@core.Color::BrightWhite).render(),
    @view.View::container([
      @widget.Text::body("↑/↓ - Scroll line by line").color(@core.Color::Gray),
      @widget.Text::body("PgUp/PgDn - Scroll page by page").color(@core.Color::Gray),
      @widget.Text::body("Tab - Switch between boxes").color(@core.Color::Gray),
      @widget.Text::body("Enter/Space - Activate buttons").color(@core.Color::Gray),
    ])
      .direction(@view.Direction::Column)
      .padding(1.0),
  ])
    .direction(@view.Direction::Column)
    .spacing(1.0)
    .padding(2.0)
}

///|
/// Create a simpler ScrollBox demo for testing
pub fn simple_scrollbox_demo_with(offset_ref : Ref[Int]) -> @view.View {
  // Create a simple list of text items
  let items : Array[&@view.Component] = []
  for i = 1; i <= 30; i = i + 1 {
    items.push(
      @widget.Text::new("Line \{i}: This is a sample text line for scrolling demonstration")
        .color(if i % 2 == 0 { @core.Color::White } else { @core.Color::Gray })
    )
  }
  
  let scroll_offset = offset_ref
  
  @view.View::container_views([
    @view.View::text("Simple ScrollBox Demo", color=@core.Color::Cyan),
    @view.View::text("Use ↑/↓ arrows to scroll", color=@core.Color::Gray),
    
    @widget.ScrollBox::new(items, visible_rows=10, offset=scroll_offset)
      .title("30 Items - Showing 10")
      .border(@view.BorderStyle::Single)
      .padding(1.0)
      .render(),
    
    @view.View::text("Current offset: \{scroll_offset.val}", color=@core.Color::Yellow),
  ])
    .direction(@view.Direction::Column)
    .spacing(1.0)
    .padding(2.0)
}

///|
/// Run the ScrollBox demo
pub fn run_scrollbox_demo() -> Unit {
  main_scrollbox_demo()
}

///|
fn main_scrollbox_demo() -> Unit {
  let app = @core.App::init()
  match app {
    None => println("Failed to initialize app")
    Some(app) => {
      // Create shared scroll offset (persist across rebuilds)
      let scroll_offset = Ref::new(0)
      
      // Build UI function
      fn build_ui() -> @view.View {
        simple_scrollbox_demo_with(scroll_offset)
      }
      
      // Run event loop
      @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
        match event {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false  // 'q' to quit
          @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
          _ => true
        }
      })
      
      app.cleanup()
    }
  }
}
