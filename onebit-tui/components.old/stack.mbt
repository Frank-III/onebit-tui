///| Stack Layout Component
///| Provides a simple stacking layout with z-index management

pub(all) enum StackDirection {
  Vertical
  Horizontal
  ZAxis  // Overlay mode
} derive(Eq)

pub(all) enum StackAlign {
  Start
  Center
  End
  Stretch
} derive(Eq)

pub(all) struct StackItem {
  content : @core.BaseRenderable
  flex : Double
  align : StackAlign?
  z_index : Int
  margin : @core.Spacing?
}

pub(all) struct Stack {
  mut base : @core.BaseRenderable
  direction : StackDirection
  spacing : Int
  align : StackAlign
  justify : StackAlign
  items : Array[StackItem]
  reverse : Bool
}

pub fn Stack::new(
  id : String,
  direction~ : StackDirection = StackDirection::Vertical,
  spacing~ : Int = 0,
  align~ : StackAlign = StackAlign::Stretch,
  justify~ : StackAlign = StackAlign::Start,
  reverse~ : Bool = false
) -> Stack {
  {
    base: @core.BaseRenderable::new(id),
    direction,
    spacing,
    align,
    justify,
    items: [],
    reverse,
  }
}

pub fn StackItem::new(
  content : @core.BaseRenderable,
  flex~ : Double = 0.0,
  align~ : StackAlign? = None,
  z_index~ : Int = 0,
  margin~ : @core.Spacing? = None
) -> StackItem {
  {
    content,
    flex,
    align,
    z_index,
    margin,
  }
}

pub fn Stack::add_item(self : Stack, item : StackItem) -> Stack {
  self.items.push(item)
  self
}

pub fn Stack::add(
  self : Stack,
  content : @core.BaseRenderable,
  flex~ : Double = 0.0
) -> Stack {
  self.add_item(StackItem::new(content, flex~))
}

/// Sort items by z-index for ZAxis stacking
fn sort_by_z_index(self : Stack) -> Array[StackItem] {
  let sorted = Array::make(self.items.length(), self.items[0])
  for i = 0; i < self.items.length(); i = i + 1 {
    sorted[i] = self.items[i]
  }
  
  // Simple bubble sort by z-index
  for i = 0; i < sorted.length() - 1; i = i + 1 {
    for j = 0; j < sorted.length() - i - 1; j = j + 1 {
      if sorted[j].z_index > sorted[j + 1].z_index {
        let temp = sorted[j]
        sorted[j] = sorted[j + 1]
        sorted[j + 1] = temp
      }
    }
  }
  
  sorted
}

/// Calculate layout for the stack
fn calculate_layout(self : Stack) -> Unit {
  if self.items.length() == 0 {
    return
  }
  
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height
  
  match self.direction {
    StackDirection::Vertical => self.layout_vertical(x, y, width, height)
    StackDirection::Horizontal => self.layout_horizontal(x, y, width, height)
    StackDirection::ZAxis => self.layout_z_axis(x, y, width, height)
  }
}

fn layout_vertical(self : Stack, x : Int, y : Int, width : Int, height : Int) -> Unit {
  // Calculate total fixed height and flex sum
  let mut fixed_height = 0
  let mut total_flex = 0.0
  let mut total_spacing = if self.items.length() > 1 { 
    self.spacing * (self.items.length() - 1) 
  } else { 
    0 
  }
  
  for item in self.items {
    if item.flex > 0.0 {
      total_flex = total_flex + item.flex
    } else {
      fixed_height = fixed_height + item.content.height
    }
    
    // Add margins
    match item.margin {
      Some(margin) => {
        fixed_height = fixed_height + margin.top + margin.bottom
      }
      None => ()
    }
  }
  
  let available_height = height - fixed_height - total_spacing
  let flex_unit = if total_flex > 0.0 && available_height > 0 {
    available_height.to_double() / total_flex
  } else {
    0.0
  }
  
  // Layout items
  let mut current_y = y
  
  // Apply justify for vertical direction
  if total_flex == 0.0 {
    let total_items_height = fixed_height + total_spacing
    current_y = match self.justify {
      StackAlign::Start => y
      StackAlign::Center => y + (height - total_items_height) / 2
      StackAlign::End => y + height - total_items_height
      StackAlign::Stretch => y
    }
  }
  
  let items_to_layout = if self.reverse {
    let mut reversed = Array::make(self.items.length(), self.items[0])
    for i = 0; i < self.items.length(); i = i + 1 {
      reversed[i] = self.items[self.items.length() - 1 - i]
    }
    reversed
  } else {
    self.items
  }
  
  for item in items_to_layout {
    // Apply top margin
    match item.margin {
      Some(margin) => {
        current_y = current_y + margin.top
      }
      None => ()
    }
    
    // Calculate item height
    let item_height = if item.flex > 0.0 {
      (item.flex * flex_unit).to_int()
    } else {
      item.content.height
    }
    
    // Calculate item width and x position based on alignment
    let item_align = match item.align {
      Some(a) => a
      None => self.align
    }
    
    let (item_x, item_width) = match item_align {
      StackAlign::Start => (x, item.content.width)
      StackAlign::Center => (x + (width - item.content.width) / 2, item.content.width)
      StackAlign::End => (x + width - item.content.width, item.content.width)
      StackAlign::Stretch => (x, width)
    }
    
    // Apply margins to width
    let final_x = match item.margin {
      Some(margin) => item_x + margin.left
      None => item_x
    }
    
    let final_width = match item.margin {
      Some(margin) => {
        if item_align == StackAlign::Stretch {
          width - margin.left - margin.right
        } else {
          item_width
        }
      }
      None => item_width
    }
    
    // Update content position and size
    item.content.x = final_x
    item.content.y = current_y
    item.content.width = final_width
    item.content.height = item_height
    
    current_y = current_y + item_height
    
    // Apply bottom margin
    match item.margin {
      Some(margin) => {
        current_y = current_y + margin.bottom
      }
      None => ()
    }
    
    // Add spacing
    current_y = current_y + self.spacing
  }
}

fn layout_horizontal(self : Stack, x : Int, y : Int, width : Int, height : Int) -> Unit {
  // Calculate total fixed width and flex sum
  let mut fixed_width = 0
  let mut total_flex = 0.0
  let mut total_spacing = if self.items.length() > 1 { 
    self.spacing * (self.items.length() - 1) 
  } else { 
    0 
  }
  
  for item in self.items {
    if item.flex > 0.0 {
      total_flex = total_flex + item.flex
    } else {
      fixed_width = fixed_width + item.content.width
    }
    
    // Add margins
    match item.margin {
      Some(margin) => {
        fixed_width = fixed_width + margin.left + margin.right
      }
      None => ()
    }
  }
  
  let available_width = width - fixed_width - total_spacing
  let flex_unit = if total_flex > 0.0 && available_width > 0 {
    available_width.to_double() / total_flex
  } else {
    0.0
  }
  
  // Layout items
  let mut current_x = x
  
  // Apply justify for horizontal direction
  if total_flex == 0.0 {
    let total_items_width = fixed_width + total_spacing
    current_x = match self.justify {
      StackAlign::Start => x
      StackAlign::Center => x + (width - total_items_width) / 2
      StackAlign::End => x + width - total_items_width
      StackAlign::Stretch => x
    }
  }
  
  let items_to_layout = if self.reverse {
    let mut reversed = Array::make(self.items.length(), self.items[0])
    for i = 0; i < self.items.length(); i = i + 1 {
      reversed[i] = self.items[self.items.length() - 1 - i]
    }
    reversed
  } else {
    self.items
  }
  
  for item in items_to_layout {
    // Apply left margin
    match item.margin {
      Some(margin) => {
        current_x = current_x + margin.left
      }
      None => ()
    }
    
    // Calculate item width
    let item_width = if item.flex > 0.0 {
      (item.flex * flex_unit).to_int()
    } else {
      item.content.width
    }
    
    // Calculate item height and y position based on alignment
    let item_align = match item.align {
      Some(a) => a
      None => self.align
    }
    
    let (item_y, item_height) = match item_align {
      StackAlign::Start => (y, item.content.height)
      StackAlign::Center => (y + (height - item.content.height) / 2, item.content.height)
      StackAlign::End => (y + height - item.content.height, item.content.height)
      StackAlign::Stretch => (y, height)
    }
    
    // Apply margins to height
    let final_y = match item.margin {
      Some(margin) => item_y + margin.top
      None => item_y
    }
    
    let final_height = match item.margin {
      Some(margin) => {
        if item_align == StackAlign::Stretch {
          height - margin.top - margin.bottom
        } else {
          item_height
        }
      }
      None => item_height
    }
    
    // Update content position and size
    item.content.x = current_x
    item.content.y = final_y
    item.content.width = item_width
    item.content.height = final_height
    
    current_x = current_x + item_width
    
    // Apply right margin
    match item.margin {
      Some(margin) => {
        current_x = current_x + margin.right
      }
      None => ()
    }
    
    // Add spacing
    current_x = current_x + self.spacing
  }
}

fn layout_z_axis(self : Stack, x : Int, y : Int, width : Int, height : Int) -> Unit {
  // For z-axis stacking, all items overlay each other
  // Sort by z-index first
  let sorted_items = self.sort_by_z_index()
  
  for item in sorted_items {
    // Calculate position based on alignment
    let item_align = match item.align {
      Some(a) => a
      None => self.align
    }
    
    let item_justify = self.justify
    
    // Calculate x position
    let item_x = match item_justify {
      StackAlign::Start => x
      StackAlign::Center => x + (width - item.content.width) / 2
      StackAlign::End => x + width - item.content.width
      StackAlign::Stretch => x
    }
    
    // Calculate y position
    let item_y = match item_align {
      StackAlign::Start => y
      StackAlign::Center => y + (height - item.content.height) / 2
      StackAlign::End => y + height - item.content.height
      StackAlign::Stretch => y
    }
    
    // Calculate size
    let item_width = if item_justify == StackAlign::Stretch {
      width
    } else {
      item.content.width
    }
    
    let item_height = if item_align == StackAlign::Stretch {
      height
    } else {
      item.content.height
    }
    
    // Apply margins
    let final_x = match item.margin {
      Some(margin) => item_x + margin.left
      None => item_x
    }
    
    let final_y = match item.margin {
      Some(margin) => item_y + margin.top
      None => item_y
    }
    
    let final_width = match item.margin {
      Some(margin) => item_width - margin.left - margin.right
      None => item_width
    }
    
    let final_height = match item.margin {
      Some(margin) => item_height - margin.top - margin.bottom
      None => item_height
    }
    
    // Update content position and size
    item.content.x = final_x
    item.content.y = final_y
    item.content.width = final_width
    item.content.height = final_height
  }
}

/// Get the base renderable with render function
pub fn Stack::as_renderable(self : Stack) -> @core.BaseRenderable {
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      self.render_stack(buffer)
    })
  }
  self.base
}

/// Render the stack
fn render_stack(self : Stack, buffer : @core.TerminalBuffer) -> Unit {
  // Fill background if needed
  if self.base.background_color != @core.RGBA::black() {
    buffer.fill_rect(
      self.base.absolute_x(),
      self.base.absolute_y(),
      self.base.width,
      self.base.height,
      ' ',
      self.base.foreground_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }
  
  // Calculate layout
  self.calculate_layout()
  
  // Render items
  let items_to_render = if self.direction == StackDirection::ZAxis {
    self.sort_by_z_index()
  } else {
    self.items
  }
  
  for item in items_to_render {
    item.content.render(buffer)
  }
}

/// Helper to set dimensions
pub fn Stack::with_dimensions(self : Stack, x : Int, y : Int, width : Int, height : Int) -> Stack {
  { ..self, base: { ..self.base, x, y, width, height } }
}

/// Helper to set background color
pub fn Stack::with_background_color(self : Stack, color : @core.RGBA) -> Stack {
  { ..self, base: { ..self.base, background_color: color } }
}

/// Builder pattern methods
pub fn Stack::with_spacing(self : Stack, spacing : Int) -> Stack {
  { ..self, spacing }
}

pub fn Stack::with_align(self : Stack, align : StackAlign) -> Stack {
  { ..self, align }
}

pub fn Stack::with_justify(self : Stack, justify : StackAlign) -> Stack {
  { ..self, justify }
}

pub fn Stack::with_reverse(self : Stack, reverse : Bool) -> Stack {
  { ..self, reverse }
}