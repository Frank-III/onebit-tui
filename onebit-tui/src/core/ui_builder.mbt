///| Clean builder API that connects existing components with Yoga layout
///| This doesn't replace components - it makes them work with Yoga


/// UI builder that wraps existing components with Yoga nodes
pub struct UIBuilder {
  yoga_node : @wrapper.Node
  component_builder : () -> BaseRenderable
  mut children : Array[UIBuilder]
}

/// Box builder - wraps existing Box component
pub fn box() -> BoxBuilder {
  {
    yoga_node: @wrapper.Node::new(),
    border: false,
    title: None,
    padding: 0.0,
    background: None,
    children: []
  }
}

pub struct BoxBuilder {
  yoga_node : @wrapper.Node
  mut border : Bool
  mut title : String?
  mut padding : Float
  mut background : RGBA?
  mut children : Array[UIBuilder]
}

// Yoga flex properties
pub fn BoxBuilder::flex_grow(self : BoxBuilder, value : Float) -> BoxBuilder {
  self.yoga_node.set_flex_grow(value)
  self
}

pub fn BoxBuilder::flex(self : BoxBuilder, value : Float) -> BoxBuilder {
  self.yoga_node.set_flex(value)
  self
}

pub fn BoxBuilder::height(self : BoxBuilder, value : Float) -> BoxBuilder {
  self.yoga_node.set_height(value)
  self
}

pub fn width(self : BoxBuilder, value : Float) -> BoxBuilder {
  self.yoga_node.set_width(value)
  self
}

pub fn align_items(self : BoxBuilder, align : @types.Align) -> BoxBuilder {
  self.yoga_node.set_align_items(align)
  self
}

pub fn justify_content(self : BoxBuilder, justify : @types.Justify) -> BoxBuilder {
  self.yoga_node.set_justify_content(justify)
  self
}

pub fn flex_direction(self : BoxBuilder, direction : @types.FlexDirection) -> BoxBuilder {
  self.yoga_node.set_flex_direction(direction)
  self
}

pub fn gap(self : BoxBuilder, gap : Float) -> BoxBuilder {
  // TODO: set_gap not implemented - self.yoga_node.set_gap(@types.Gutter::All, gap)
  self
}

// Component properties
pub fn BoxBuilder::border(self : BoxBuilder, enabled : Bool) -> BoxBuilder {
  self.border = enabled
  self
}

pub fn BoxBuilder::title(self : BoxBuilder, title : String) -> BoxBuilder {
  self.title = Some(title)
  self
}

pub fn padding(self : BoxBuilder, padding : Float) -> BoxBuilder {
  self.padding = padding
  self.yoga_node.set_padding(@types.Edge::All, @types.Value::point(padding.to_double().to_float()))
  self
}

pub fn background(self : BoxBuilder, color : RGBA) -> BoxBuilder {
  self.background = Some(color)
  self
}

// Children
pub fn child(self : BoxBuilder, child : UIBuilder) -> BoxBuilder {
  self.yoga_node.add_child(child.yoga_node)
  self.children.push(child)
  self
}

pub fn children(self : BoxBuilder, children : Array[UIBuilder]) -> BoxBuilder {
  for i = 0; i < children.length(); i = i + 1 {
    self.yoga_node.add_child(children[i].yoga_node)
    self.children.push(children[i])
  }
  self
}

pub fn BoxBuilder::build(self : BoxBuilder) -> UIBuilder {
  let border = self.border
  let title = self.title
  let background = self.background
  let padding = self.padding.to_double().to_int()
  
  UIBuilder {
    yoga_node: self.yoga_node,
    component_builder: fn() {
      let box_comp = @components.Box::new("box_" + "1")
      if border {
        box.border_style = BorderStyle::Single
      }
      match title {
        Some(t) => box.title = Some(t)
        None => ()
      }
      match background {
        Some(bg) => box.base.background_color = bg
        None => ()
      }
      box.padding = padding
      box.as_renderable()
    },
    children: self.children
  }
}

/// Text builder
pub fn text(content : String) -> TextBuilder {
  TextBuilder {
    yoga_node: @wrapper.Node::new(),
    content: content,
    color: None,
    bold: false
  }
}

pub struct TextBuilder {
  yoga_node : @wrapper.Node
  content : String
  mut color : RGBA?
  mut bold : Bool
}

pub fn color(self : TextBuilder, color : RGBA) -> TextBuilder {
  self.color = Some(color)
  self
}

pub fn bold(self : TextBuilder) -> TextBuilder {
  self.bold = true
  self
}

pub fn TextBuilder::build(self : TextBuilder) -> UIBuilder {
  let content = self.content
  let color = self.color
  let bold = self.bold
  
  UIBuilder {
    yoga_node: self.yoga_node,
    component_builder: fn() {
      let text_comp = @components.Text::new("text_" + "1", content)
      match color {
        Some(c) => text.base.foreground_color = c
        None => ()
      }
      if bold {
        text.style = TextStyle::Bold
      }
      text.as_renderable()
    },
    children: []
  }
}

/// Layout helpers
pub fn hstack() -> BoxBuilder {
  box().flex_direction(@types.FlexDirection::Row)
}

pub fn vstack() -> BoxBuilder {
  box().flex_direction(@types.FlexDirection::Column)
}

pub fn center() -> BoxBuilder {
  box()
    .align_items(@types.Align::Center)
    .justify_content(@types.Justify::Center)
}

/// Spacer - just a box with flex_grow
pub fn spacer() -> UIBuilder {
  box().flex_grow(1.0).build()
}

/// List builder
pub fn list(items : Array[String]) -> ListBuilder {
  ListBuilder {
    yoga_node: @wrapper.Node::new(),
    items: items,
    selected: 0,
    border: false,
    title: None
  }
}

pub struct ListBuilder {
  yoga_node : @wrapper.Node
  items : Array[String]
  mut selected : Int
  mut border : Bool
  mut title : String?
}

pub fn ListBuilder::flex_grow(self : ListBuilder, value : Float) -> ListBuilder {
  self.yoga_node.set_flex_grow(value)
  self
}

pub fn ListBuilder::flex(self : ListBuilder, value : Float) -> ListBuilder {
  self.yoga_node.set_flex(value)
  self
}

pub fn ListBuilder::height(self : ListBuilder, value : Float) -> ListBuilder {
  self.yoga_node.set_height(value)
  self
}

pub fn ListBuilder::border(self : ListBuilder, enabled : Bool) -> ListBuilder {
  self.border = enabled
  self
}

pub fn ListBuilder::title(self : ListBuilder, title : String) -> ListBuilder {
  self.title = Some(title)
  self
}

pub fn ListBuilder::selected(self : ListBuilder, index : Int) -> ListBuilder {
  self.selected = index
  self
}

pub fn ListBuilder::build(self : ListBuilder) -> UIBuilder {
  let items = self.items
  let selected = self.selected
  let border = self.border
  let title = self.title
  
  UIBuilder {
    yoga_node: self.yoga_node,
    component_builder: fn() {
      // Convert strings to ListItems
      let list_items : Array[@components.ListItem] = []
      for i = 0; i < items.length(); i = i + 1 {
        list_items.push({
          id: i.to_string(),
          text: items[i],
          icon: None,
          data: None
        })
      }
      
      let list_comp = @components.List::new("list_" + "1", list_items)
      list.selected_index = selected
      if border {
        list.border_style = BorderStyle::Single
      }
      match title {
        Some(t) => list.title = Some(t)
        None => ()
      }
      list.as_renderable()
    },
    children: []
  }
}

/// Select builder
pub fn select(options : Array[String]) -> SelectBuilder {
  SelectBuilder {
    yoga_node: @wrapper.Node::new(),
    options: options,
    selected: 0,
    border: false
  }
}

pub struct SelectBuilder {
  yoga_node : @wrapper.Node
  options : Array[String]
  mut selected : Int
  mut border : Bool
}

pub fn SelectBuilder::flex_grow(self : SelectBuilder, value : Float) -> SelectBuilder {
  self.yoga_node.set_flex_grow(value)
  self
}

pub fn SelectBuilder::height(self : SelectBuilder, value : Float) -> SelectBuilder {
  self.yoga_node.set_height(value)
  self
}

pub fn SelectBuilder::border(self : SelectBuilder, enabled : Bool) -> SelectBuilder {
  self.border = enabled
  self
}

pub fn SelectBuilder::selected(self : SelectBuilder, index : Int) -> SelectBuilder {
  self.selected = index
  self
}

pub fn SelectBuilder::build(self : SelectBuilder) -> UIBuilder {
  let options = self.options
  let selected = self.selected
  let border = self.border
  
  UIBuilder {
    yoga_node: self.yoga_node,
    component_builder: fn() {
      // Convert strings to SelectItems
      let select_items : Array[@components.SelectItem] = []
      for i = 0; i < options.length(); i = i + 1 {
        select_items.push(
          @components.SelectItem::new(options[i], i.to_string(), i == selected)
        )
      }
      
      let select_comp = @components.Select::new(select_items)
      if border {
        select.border_style = BorderStyle::Single
      }
      select.as_renderable()
    },
    children: []
  }
}

/// Build and render the UI tree
pub fn UIBuilder::render(self : UIBuilder, buffer : @ffi.Buffer) -> Unit {
  // Get layout from Yoga
  let layout : @yoga_ffi.Layout = self.yoga_node.get_layout()
  
  // Create and position the actual component
  let component = (self.component_builder)()
  // Now we can access layout fields
  component.x = layout.left.to_double().to_int()
  component.y = layout.top.to_double().to_int()
  component.width = layout.width.to_double().to_int()
  component.height = layout.height.to_double().to_int()
  
  // Render component
  component.render(buffer)
  
  // Render children
  for i = 0; i < self.children.length(); i = i + 1 {
    self.children[i].render(buffer)
  }
}

/// Calculate layout for the entire tree
pub fn UIBuilder::calculate_layout(self : UIBuilder, width : Float, height : Float) -> Unit {
  self.yoga_node.calculate_layout(width, height, @types.Direction::LTR)
}