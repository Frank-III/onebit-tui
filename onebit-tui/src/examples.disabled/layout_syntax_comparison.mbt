///| Comparison of old vs new layout syntax

// OLD WAY - verbose and imperative
fn create_layout_old() -> @components.LayoutBox {
  let container = @components.LayoutBox::row("container")
  container.set_style(
    @core.LayoutStyle::{
      flex_direction: Some(@yoga/types.FlexDirection::Row),
      padding: @core.Map::new(),
      margin: @core.Map::new(),
      // ... lots of boilerplate
    }
  )
  
  let sidebar = @components.LayoutBox::column("sidebar") 
  sidebar.layout_node.style.width = Some(@yoga/types.Value::point(200.0))
  container.add_child(sidebar)
  
  let content = @components.LayoutBox::new("content")
  content.layout_node.style.flex = Some(1.0)
  container.add_child(content)
  
  container
}

// NEW WAY - declarative and concise
fn create_layout_new() -> @components.LayoutBox {
  @components.hstack("container", [
    @components.LayoutBox::column("sidebar").with_width(200.0),
    @components.LayoutBox::new("content").with_flex(1.0)
  ])
}

// More complex example - OLD WAY
fn create_app_old() -> @components.LayoutBox {
  let app = @components.LayoutBox::column("app")
  
  let header = @components.LayoutBox::new("header")
  header.layout_node.style.height = Some(@yoga/types.Value::point(60.0))
  header.title = Some("My App")
  header.border_style = @core.BorderStyle::Single
  app.add_child(header)
  
  let body = @components.LayoutBox::row("body")
  body.layout_node.style.flex = Some(1.0)
  
  let nav = @components.LayoutBox::new("nav")
  nav.layout_node.style.width = Some(@yoga/types.Value::point(200.0))
  nav.layout_node.style.padding[@yoga/types.Edge::All] = @yoga/types.Value::point(10.0)
  body.add_child(nav)
  
  let content = @components.LayoutBox::new("content")
  content.layout_node.style.flex = Some(1.0)
  body.add_child(content)
  
  app.add_child(body)
  
  let footer = @components.LayoutBox::new("footer")
  footer.layout_node.style.height = Some(@yoga/types.Value::point(40.0))
  app.add_child(footer)
  
  app
}

// More complex example - NEW WAY
fn create_app_new() -> @components.LayoutBox {
  @components.vstack("app", [
    @components.fixed_box("header", 0.0, 60.0)
      .with_title("My App")
      .with_border(@core.BorderStyle::Single)
      .with_flex(1.0),  // width: 100%
      
    @components.hstack("body", [
      @components.LayoutBox::new("nav")
        .with_width(200.0)
        .with_padding(10.0),
      
      @components.LayoutBox::new("content")
        .with_flex(1.0)
    ]).with_flex(1.0),
    
    @components.fixed_box("footer", 0.0, 40.0)
      .with_flex(1.0)  // width: 100%
  ])
}

// Even more concise with helper functions
fn create_split_pane(
  left_content : @components.LayoutElement,
  right_content : @components.LayoutElement,
  split_ratio : Float
) -> @components.LayoutBox {
  @components.hstack("split-pane", [
    left_content.get_layout_box().with_flex(split_ratio),
    right_content.get_layout_box().with_flex(1.0 - split_ratio)
  ])
}

// Usage
fn main {
  let app = @components.vstack("app", [
    // Header with logo and menu
    @components.hstack("header", [
      @components.fixed_box("logo", 100.0, 50.0),
      @components.spacer("header-space"),
      @components.hstack("menu", [
        @components.LayoutBox::new("file").with_padding(5.0),
        @components.LayoutBox::new("edit").with_padding(5.0),
        @components.LayoutBox::new("view").with_padding(5.0)
      ])
    ]).with_height(50.0),
    
    // Main content with split pane
    create_split_pane(
      @components.vstack("sidebar", [
        @components.LayoutBox::new("search").with_height(30.0),
        @components.LayoutBox::new("tree").with_flex(1.0)
      ]),
      @components.centered("editor", 
        @components.LayoutBox::new("code")
          .with_title("main.mbt")
          .with_border(@core.BorderStyle::Rounded)
      ),
      0.3  // 30/70 split
    ).with_flex(1.0),
    
    // Status bar
    @components.LayoutBox::row("status")
      .with_height(20.0)
      .with_padding(5.0)
  ])
  
  // The entire app layout is defined declaratively!
  ()
}