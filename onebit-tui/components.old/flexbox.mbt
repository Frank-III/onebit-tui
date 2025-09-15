///| FlexBox Layout Component
///| Provides flexible box layout with direction, alignment, and spacing options

pub enum FlexDirection {
  Row
  Column
  RowReverse
  ColumnReverse
}

pub enum FlexAlign {
  Start
  Center
  End
  Stretch
  SpaceBetween
  SpaceAround
  SpaceEvenly
}

pub enum FlexWrap {
  NoWrap
  Wrap
  WrapReverse
}

pub struct FlexItem {
  content : @core.CustomRenderable  // Using concrete type instead of trait
  flex_grow : Double
  flex_shrink : Double
  flex_basis : Int  // Width for row, height for column (-1 for auto)
  align_self : FlexAlign?
  margin : @core.Spacing
}

pub struct FlexBox {
  direction : FlexDirection
  justify_content : FlexAlign
  align_items : FlexAlign
  align_content : FlexAlign
  wrap : FlexWrap
  gap : Int
  padding : @core.Spacing
  background : @core.RGBA?
  border : @core.BorderStyleExt?
  mut items : FixedArray[FlexItem]  // Made mutable
  mut width : UInt
  mut height : UInt
}

pub fn FlexBox::new(
  direction~ : FlexDirection = Row,
  justify_content~ : FlexAlign = Start,
  align_items~ : FlexAlign = Stretch,
  align_content~ : FlexAlign = Start,
  wrap~ : FlexWrap = NoWrap,
  gap~ : Int = 0,
  padding~ : @core.Spacing = @core.Spacing::zero(),
  background~ : @core.RGBA? = None,
  border~ : @core.BorderStyleExt? = None
) -> FlexBox {
  FlexBox::{
    direction,
    justify_content,
    align_items,
    align_content,
    wrap,
    gap,
    padding,
    background,
    border,
    items: FixedArray::make(0, FlexItem::default()),
    width: 0,
    height: 0
  }
}

pub fn FlexItem::new(
  content : @core.CustomRenderable,
  flex_grow~ : Double = 0.0,
  flex_shrink~ : Double = 1.0,
  flex_basis~ : Int = -1,
  align_self~ : FlexAlign? = None,
  margin~ : @core.Spacing = @core.Spacing::zero()
) -> FlexItem {
  FlexItem::{
    content,
    flex_grow,
    flex_shrink,
    flex_basis,
    align_self,
    margin
  }
}

pub fn FlexItem::default() -> FlexItem {
  // Create an empty renderable that does nothing
  let empty_render = @core.CustomRenderable::new(
    fn(buffer, x, y, width, height) {
      // Do nothing
    }
  )
  
  FlexItem::{
    content: empty_render,
    flex_grow: 0.0,
    flex_shrink: 1.0,
    flex_basis: -1,
    align_self: None,
    margin: @core.Spacing::zero()
  }
}

pub fn FlexBox::add_item(self : FlexBox, item : FlexItem) -> Unit {
  // Create new array with one more slot
  let new_items = FixedArray::make(self.items.length() + 1, FlexItem::default())
  
  // Copy existing items
  for i = 0; i < self.items.length(); i = i + 1 {
    new_items[i] = self.items[i]
  }
  
  // Add new item
  new_items[self.items.length()] = item
  self.items = new_items
}

pub fn FlexBox::add(
  self : FlexBox,
  content : @core.CustomRenderable,
  flex_grow~ : Double = 0.0,
  flex_shrink~ : Double = 1.0,
  flex_basis~ : Int = -1
) -> Unit {
  self.add_item(FlexItem::new(
    content,
    flex_grow=flex_grow,
    flex_shrink=flex_shrink,
    flex_basis=flex_basis
  ))
}

fn calculate_main_axis_size(self : FlexBox) -> (Int, Bool) {
  match self.direction {
    Row | RowReverse => (self.width.reinterpret_as_int(), true)
    Column | ColumnReverse => (self.height.reinterpret_as_int(), false)
  }
}

fn calculate_cross_axis_size(self : FlexBox) -> (Int, Bool) {
  match self.direction {
    Row | RowReverse => (self.height.reinterpret_as_int(), false)
    Column | ColumnReverse => (self.width.reinterpret_as_int(), true)
  }
}

pub fn FlexBox::layout(self : FlexBox, width : UInt, height : UInt) -> Unit {
  self.width = width
  self.height = height
  
  // Skip if no items
  if self.items.length() == 0 {
    return
  }
  
  let (main_size, is_horizontal) = self.calculate_main_axis_size()
  let (cross_size, _) = self.calculate_cross_axis_size()
  
  // Account for padding
  let available_main = main_size - 
    (if is_horizontal { self.padding.left + self.padding.right } 
     else { self.padding.top + self.padding.bottom })
  let available_cross = cross_size - 
    (if is_horizontal { self.padding.top + self.padding.bottom }
     else { self.padding.left + self.padding.right })
  
  // Calculate total gap space
  let total_gap = self.gap * (self.items.length() - 1)
  let mut remaining_main = available_main - total_gap
  
  // First pass: Calculate flex basis and identify flexible items
  let mut total_flex_grow = 0.0
  let mut total_flex_shrink = 0.0
  let mut total_basis = 0
  
  for i = 0; i < self.items.length(); i = i + 1 {
    let item = self.items[i]
    
    // Calculate basis
    let basis = if item.flex_basis >= 0 {
      item.flex_basis
    } else {
      // Auto-size based on content
      10  // Default size for now
    }
    
    total_basis = total_basis + basis
    
    if item.flex_grow > 0.0 {
      total_flex_grow = total_flex_grow + item.flex_grow
    }
    if item.flex_shrink > 0.0 {
      total_flex_shrink = total_flex_shrink + item.flex_shrink
    }
  }
  
  // Calculate flex factor
  let flex_space = remaining_main - total_basis
  let growing = flex_space > 0
  
  // TODO: Complete layout calculation
  // This is a simplified version - full flexbox algorithm is complex
}

pub fn FlexBox::render(self : FlexBox, buffer : @ffi.Buffer) -> Unit {
  // Draw background if specified
  match self.background {
    Some(bg) => {
      buffer.fill_rect(
        0, 0, self.width, self.height,
        bg.r, bg.g, bg.b, bg.a
      )
    }
    None => ()
  }
  
  // Draw border if specified
  match self.border {
    Some(border) => {
      // Draw border using box drawing characters
      let border_chars = FixedArray::make(6, 0_U)
      border_chars[0] = 0x250C_U // ┌
      border_chars[1] = 0x2500_U // ─
      border_chars[2] = 0x2510_U // ┐
      border_chars[3] = 0x2502_U // │
      border_chars[4] = 0x2514_U // └
      border_chars[5] = 0x2518_U // ┘
      
      let border_color = FixedArray::make(4, 0.0)
      border_color[0] = border.color.r
      border_color[1] = border.color.g
      border_color[2] = border.color.b
      border_color[3] = border.color.a
      
      let bg_color = FixedArray::make(4, 0.0)
      bg_color[0] = 0.0; bg_color[1] = 0.0; bg_color[2] = 0.0; bg_color[3] = 0.0
      
      buffer.draw_box(
        0, 0, self.width, self.height,
        border_chars,
        0_U,  // No fill
        border_color, bg_color,
        title=""
      )
    }
    None => ()
  }
  
  // Simplified rendering - just stack items for now
  let mut current_x = self.padding.left.reinterpret_as_uint()
  let mut current_y = self.padding.top.reinterpret_as_uint()
  
  match self.direction {
    Row => {
      for i = 0; i < self.items.length(); i = i + 1 {
        let item = self.items[i]
        
        // Render item at current position
        // TODO: Proper item rendering with calculated sizes
        
        // Move to next position
        current_x = current_x + 10_U + self.gap.reinterpret_as_uint()
      }
    }
    Column => {
      for i = 0; i < self.items.length(); i = i + 1 {
        let item = self.items[i]
        
        // Render item at current position
        // TODO: Proper item rendering with calculated sizes
        
        // Move to next position
        current_y = current_y + 2_U + self.gap.reinterpret_as_uint()
      }
    }
    _ => ()
  }
}

// Implement Renderable for FlexBox
pub fn FlexBox::to_renderable(self : FlexBox) -> @core.CustomRenderable {
  @core.CustomRenderable::new(
    fn(buffer, x, y, width, height) {
      self.layout(width, height)
      self.render(buffer)
    }
  )
}