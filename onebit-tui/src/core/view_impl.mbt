///| Implementation of view rendering

/// Box rendering
pub fn BoxView::render(self : BoxView, ctx : RenderContext) -> Unit {
  let x = ctx.bounds.x
  let y = ctx.bounds.y
  let width = ctx.bounds.width
  let height = ctx.bounds.height
  
  // Fill background
  ctx.buffer.fill_rect(x, y, width, height, ' ', RGBA::white(), self.background, TextStyle::None)
  
  // Draw border
  if self.border != BorderStyle::None {
    self.draw_border(ctx)
  }
  
  // Calculate content area
  let content_bounds = self.content_bounds(ctx.bounds)
  
  // Render children with layout
  let child_ctx = RenderContext::{ buffer: ctx.buffer, bounds: content_bounds }
  self.layout_children(child_ctx)
}

pub fn BoxView::measure(self : BoxView, constraints : Constraints) -> ViewSize {
  // Measure children and add padding/border
  let border_size = if self.border == BorderStyle::None { 0 } else { 2 }
  let total_padding = self.padding * 2 + border_size
  
  // For now, just use the constraints max
  { 
    width: constraints.max_width,
    height: constraints.max_height
  }
}

fn BoxView::content_bounds(self : BoxView, bounds : Rect) -> Rect {
  let border_width = if self.border == BorderStyle::None { 0 } else { 1 }
  let title_height = match self.title {
    Some(_) => 1
    None => 0
  }
  
  Rect::new(
    bounds.x + border_width + self.padding,
    bounds.y + border_width + self.padding + title_height,
    bounds.width - (border_width + self.padding) * 2,
    bounds.height - (border_width + self.padding) * 2 - title_height
  )
}

fn BoxView::layout_children(self : BoxView, ctx : RenderContext) -> Unit {
  // For now, just render first child filling the space
  if self.children.length() > 0 {
    self.children[0].render(ctx)
  }
}

fn BoxView::draw_border(self : BoxView, ctx : RenderContext) -> Unit {
  let chars = border_chars(self.border)
  let x = ctx.bounds.x
  let y = ctx.bounds.y
  let width = ctx.bounds.width
  let height = ctx.bounds.height
  
  // Corners
  ctx.buffer.write_char(x, y, chars.top_left, self.border_color, self.background, TextStyle::None)
  ctx.buffer.write_char(x + width - 1, y, chars.top_right, self.border_color, self.background, TextStyle::None)
  ctx.buffer.write_char(x, y + height - 1, chars.bottom_left, self.border_color, self.background, TextStyle::None)
  ctx.buffer.write_char(x + width - 1, y + height - 1, chars.bottom_right, self.border_color, self.background, TextStyle::None)
  
  // Horizontal lines
  for i = 1; i < width - 1; i = i + 1 {
    ctx.buffer.write_char(x + i, y, chars.horizontal, self.border_color, self.background, TextStyle::None)
    ctx.buffer.write_char(x + i, y + height - 1, chars.horizontal, self.border_color, self.background, TextStyle::None)
  }
  
  // Vertical lines
  for i = 1; i < height - 1; i = i + 1 {
    ctx.buffer.write_char(x, y + i, chars.vertical, self.border_color, self.background, TextStyle::None)
    ctx.buffer.write_char(x + width - 1, y + i, chars.vertical, self.border_color, self.background, TextStyle::None)
  }
  
  // Title
  match self.title {
    Some(title) => {
      let title_x = x + width / 2 - title.length() / 2
      if title_x > x && title_x + title.length() < x + width {
        ctx.buffer.write_string(title_x, y, title, self.border_color, self.background, TextStyle::None)
      }
    }
    None => ()
  }
}

/// Text rendering
pub fn TextView::render(self : TextView, ctx : RenderContext) -> Unit {
  // Simple rendering for now - just draw at top-left of bounds
  let lines = self.wrap_text(ctx.bounds.width)
  let mut y = ctx.bounds.y
  
  for line in lines {
    if y >= ctx.bounds.y + ctx.bounds.height {
      break
    }
    
    let x = match self.align {
      TextAlign::Left => ctx.bounds.x
      TextAlign::Center => ctx.bounds.x + (ctx.bounds.width - line.length()) / 2
      TextAlign::Right => ctx.bounds.x + ctx.bounds.width - line.length()
    }
    
    ctx.buffer.write_string(x, y, line, self.color, RGBA::black(), self.style)
    y = y + 1
  }
}

pub fn TextView::measure(self : TextView, constraints : Constraints) -> ViewSize {
  let lines = self.wrap_text(constraints.max_width)
  let max_width = lines.fold(init=0, fn(max, line) { 
    let len = line.length()
    if len > max { len } else { max } 
  })
  {
    width: max_width,
    height: lines.length()
  }
}

fn TextView::wrap_text(self : TextView, max_width : Int) -> Array[String] {
  // Simple implementation - just split on newlines for now
  let lines = []
  let mut current = ""
  for i = 0; i < self.content.length(); i = i + 1 {
    let ch = self.content[i]
    if ch == '\n' {
      lines.push(current)
      current = ""
    } else {
      current = current + ch.to_string()
    }
  }
  if current.length() > 0 {
    lines.push(current)
  }
  lines
}

/// Group rendering - just render children
pub fn GroupView::render(self : GroupView, ctx : RenderContext) -> Unit {
  for child in self.children {
    child.render(ctx)
  }
}

pub fn GroupView::measure(self : GroupView, constraints : Constraints) -> ViewSize {
  // Group takes the size of its constraints
  { width: constraints.max_width, height: constraints.max_height }
}

/// VStack rendering
pub fn VStackView::render(self : VStackView, ctx : RenderContext) -> Unit {
  let mut y = ctx.bounds.y
  
  for i = 0; i < self.children.length(); i = i + 1 {
    let child = self.children[i]
    let child_height = ctx.bounds.height / self.children.length() // Simple equal distribution
    
    let child_bounds = Rect::new(
      ctx.bounds.x,
      y,
      ctx.bounds.width,
      child_height
    )
    
    child.render({ buffer: ctx.buffer, bounds: child_bounds })
    y = y + child_height + self.spacing
  }
}

pub fn VStackView::measure(self : VStackView, constraints : Constraints) -> ViewSize {
  // Simple implementation
  { width: constraints.max_width, height: constraints.max_height }
}

/// HStack rendering
pub fn HStackView::render(self : HStackView, ctx : RenderContext) -> Unit {
  let mut x = ctx.bounds.x
  
  for i = 0; i < self.children.length(); i = i + 1 {
    let child = self.children[i]
    let child_width = ctx.bounds.width / self.children.length() // Simple equal distribution
    
    let child_bounds = Rect::new(
      x,
      ctx.bounds.y,
      child_width,
      ctx.bounds.height
    )
    
    child.render({ buffer: ctx.buffer, bounds: child_bounds })
    x = x + child_width + self.spacing
  }
}

pub fn HStackView::measure(self : HStackView, constraints : Constraints) -> ViewSize {
  // Simple implementation
  { width: constraints.max_width, height: constraints.max_height }
}

/// ZStack rendering
pub fn ZStackView::render(self : ZStackView, ctx : RenderContext) -> Unit {
  // Render all children in same bounds (overlapping)
  for child in self.children {
    child.render(ctx)
  }
}

pub fn ZStackView::measure(self : ZStackView, constraints : Constraints) -> ViewSize {
  { width: constraints.max_width, height: constraints.max_height }
}

/// Spacer rendering
pub fn SpacerView::render(self : SpacerView, _ctx : RenderContext) -> Unit {
  // Spacer renders nothing
}

pub fn SpacerView::measure(self : SpacerView, constraints : Constraints) -> ViewSize {
  { width: self.min_length, height: self.min_length }
}

/// Padding rendering
pub fn PaddingView::render(self : PaddingView, ctx : RenderContext) -> Unit {
  let padded_bounds = Rect::new(
    ctx.bounds.x + self.amount,
    ctx.bounds.y + self.amount,
    ctx.bounds.width - self.amount * 2,
    ctx.bounds.height - self.amount * 2
  )
  
  self.child.render({ buffer: ctx.buffer, bounds: padded_bounds })
}

pub fn PaddingView::measure(self : PaddingView, constraints : Constraints) -> ViewSize {
  let child_constraints = Constraints::{
    min_width: constraints.min_width - self.amount * 2,
    max_width: constraints.max_width - self.amount * 2,
    min_height: constraints.min_height - self.amount * 2,
    max_height: constraints.max_height - self.amount * 2
  }
  
  let child_size = self.child.measure(child_constraints)
  ViewSize::{
    width: child_size.width + self.amount * 2,
    height: child_size.height + self.amount * 2
  }
}

/// Border character helper
struct BorderChars {
  horizontal : Char
  vertical : Char
  top_left : Char
  top_right : Char
  bottom_left : Char
  bottom_right : Char
}

fn border_chars(style : BorderStyle) -> BorderChars {
  match style {
    BorderStyle::None => { horizontal: ' ', vertical: ' ', top_left: ' ', top_right: ' ', bottom_left: ' ', bottom_right: ' ' }
    BorderStyle::Single => { horizontal: '─', vertical: '│', top_left: '┌', top_right: '┐', bottom_left: '└', bottom_right: '┘' }
    BorderStyle::Double => { horizontal: '═', vertical: '║', top_left: '╔', top_right: '╗', bottom_left: '╚', bottom_right: '╝' }
    BorderStyle::Thick => { horizontal: '━', vertical: '┃', top_left: '┏', top_right: '┓', bottom_left: '┗', bottom_right: '┛' }
    BorderStyle::Rounded => { horizontal: '─', vertical: '│', top_left: '╭', top_right: '╮', bottom_left: '╰', bottom_right: '╯' }
    BorderStyle::Dashed => { horizontal: '┄', vertical: '┆', top_left: '┌', top_right: '┐', bottom_left: '└', bottom_right: '┘' }
    BorderStyle::Dotted => { horizontal: '┈', vertical: '┊', top_left: '┌', top_right: '┐', bottom_left: '└', bottom_right: '┘' }
  }
}