///| View component - base container using Yoga layout

///|
/// Similar to React Native's View or HTML's div
pub struct View {
  // Layout
  yoga_node : @wrapper.Node
  layout_props : LayoutProps
  computed : ComputedLayout?

  // Style
  background_color : @core.Color?
  border_color : @core.Color?
  border_style : BorderStyle?

  // Children
  mut children : Array[View]

  // Content (for leaf nodes)
  text_content : String?
  text_color : @core.Color?
}

///|
pub enum BorderStyle {
  None
  Single
  Double
  Rounded
}

///|
pub fn View::new() -> View {
  let config = @wrapper.Config::new()
  let node = @wrapper.Node::new_with_config(config)
  {
    yoga_node: node,
    layout_props: default_layout_props(),
    computed: None,
    background_color: None,
    border_color: None,
    border_style: None,
    children: [],
    text_content: None,
    text_color: None,
  }
}

///|
fn default_layout_props() -> LayoutProps {
  {
    flex_grow: None,
    flex_shrink: None,
    flex_basis: None,
    flex_direction: None,
    flex_wrap: None,
    align_items: None,
    align_self: None,
    align_content: None,
    justify_content: None,
    width: None,
    height: None,
    min_width: None,
    min_height: None,
    max_width: None,
    max_height: None,
    padding: None,
    margin: None,
    gap: None,
    row_gap: None,
    column_gap: None,
    position_type: None,
    top: None,
    right: None,
    bottom: None,
    left: None,
  }
}

// Builder pattern for View

///|
pub fn View::flex_direction(self : View, dir : FlexDirection) -> View {
  self.layout_props.flex_direction = Some(dir)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::justify_content(self : View, justify : Justify) -> View {
  self.layout_props.justify_content = Some(justify)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::align_items(self : View, align : Align) -> View {
  self.layout_props.align_items = Some(align)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::padding(self : View, value : Double) -> View {
  self.layout_props.padding = Some(EdgeValues::all(value))
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::margin(self : View, value : Double) -> View {
  self.layout_props.margin = Some(EdgeValues::all(value))
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::flex(self : View, value : Double) -> View {
  self.layout_props.flex_grow = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::width(self : View, value : SizeValue) -> View {
  self.layout_props.width = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::height(self : View, value : SizeValue) -> View {
  self.layout_props.height = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::background(self : View, color : @core.Color) -> View {
  self.background_color = Some(color)
  self
}

///|
pub fn View::border(
  self : View,
  style : BorderStyle,
  color : @core.Color,
) -> View {
  self.border_style = Some(style)
  self.border_color = Some(color)
  // Borders take 1 cell, so add padding to Yoga
  self.yoga_node.set_border(@wrapper.Edge::All, 1.0)
  self
}

// Add a child view

///|
pub fn View::add_child(self : View, child : View) -> View {
  self.children.push(child)
  // Insert child's Yoga node
  self.yoga_node.insert_child(child.yoga_node, self.children.length() - 1)
  self
}

// Create a text view

///|
pub fn View::text(content : String, color : @core.Color?) -> View {
  let view = View::new()
  view.text_content = Some(content)
  view.text_color = color

  // Text has intrinsic size
  let width = content.length().to_double()
  let height = 1.0 // Single line for now
  view.yoga_node.set_width(width.to_float())
  view.yoga_node.set_height(height.to_float())
  view
}

// Calculate layout for entire tree

///|
pub fn View::calculate_layout(
  self : View,
  available_width : Double,
  available_height : Double,
) -> Unit {
  self.yoga_node.calculate_layout(
    available_width.to_float(),
    available_height.to_float(),
    @wrapper.Direction::LTR,
  )

  // Store computed layout
  self.update_computed_layout()

  // Update children
  for i = 0; i < self.children.length(); i = i + 1 {
    self.children[i].update_computed_layout()
  }
}

///|
fn View::update_computed_layout(self : View) -> Unit {
  let layout = self.yoga_node.get_computed_layout()
  self.computed = Some({
    x: layout.left.to_double(),
    y: layout.top.to_double(),
    width: layout.width.to_double(),
    height: layout.height.to_double(),
  })

  // Recursively update children
  for i = 0; i < self.children.length(); i = i + 1 {
    self.children[i].update_computed_layout()
  }
}

// Render the view tree

///|
pub fn View::render(
  self : View,
  app : @core.App,
  parent_x : Int,
  parent_y : Int,
) -> Unit {
  match self.computed {
    None => return // Not laid out yet
    Some(layout) => {
      let x = parent_x + layout.x.to_int()
      let y = parent_y + layout.y.to_int()
      let width = layout.width.to_int()
      let height = layout.height.to_int()

      // Draw background
      match self.background_color {
        Some(color) => app.draw_rect(x, y, width, height, color)
        None => ()
      }

      // Draw border
      match self.border_style {
        Some(style) => self.draw_border(app, x, y, width, height, style)
        None => ()
      }

      // Draw text content if present
      match self.text_content {
        Some(text) => {
          let text_color = self.text_color.unwrap_or(@core.Color::White)
          app.draw_text(text, x, y, text_color)
        }
        None => ()
      }

      // Render children
      for i = 0; i < self.children.length(); i = i + 1 {
        self.children[i].render(app, x, y)
      }
    }
  }
}

///|
fn View::draw_border(
  self : View,
  app : @core.App,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  style : BorderStyle,
) -> Unit {
  let color = self.border_color.unwrap_or(@core.Color::White)

  // Get border characters based on style
  let (tl, t, tr, l, r, bl, b, br) = match style {
    Single => ("┌", "─", "┐", "│", "│", "└", "─", "┘")
    Double => ("╔", "═", "╗", "║", "║", "╚", "═", "╝")
    Rounded => ("╭", "─", "╮", "│", "│", "╰", "─", "╯")
    None => return
  }

  // Top border
  app.draw_text(tl, x, y, color)
  for i = 1; i < width - 1; i = i + 1 {
    app.draw_text(t, x + i, y, color)
  }
  app.draw_text(tr, x + width - 1, y, color)

  // Side borders
  for i = 1; i < height - 1; i = i + 1 {
    app.draw_text(l, x, y + i, color)
    app.draw_text(r, x + width - 1, y + i, color)
  }

  // Bottom border
  app.draw_text(bl, x, y + height - 1, color)
  for i = 1; i < width - 1; i = i + 1 {
    app.draw_text(b, x + i, y + height - 1, color)
  }
  app.draw_text(br, x + width - 1, y + height - 1, color)
}

// Helper to unwrap Option

///|
fn[T] Option::unwrap_or(self : T?, default : T) -> T {
  match self {
    Some(value) => value
    None => default
  }
}
