///|
/// Box component using BaseRenderable architecture

///|
/// Box component with borders and content area
pub struct Box {
  mut base : @core.BaseRenderable
  border_style : @core.BorderStyle
  border_color : @core.RGBA
  title : String?
  title_align : @core.TextAlign
  padding : Int
}

///|
pub fn Box::new(id : String) -> Box {
  {
    base: @core.BaseRenderable::new(id),
    border_style: @core.BorderStyle::Single,
    border_color: @core.RGBA::white(),
    title: None,
    title_align: @core.TextAlign::Center,
    padding: 1,
  }
}

///|
/// Get the base renderable
pub fn Box::as_renderable(self : Box) -> @core.BaseRenderable {
  // Set up the render function if not already set
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      // Find the Box instance from the base
      // This is a workaround since we can't store the Box directly
      self.render_box(buffer)
    })
  }
  self.base
}

///|
/// Render this box (not including children)
fn render_box(self : Box, buffer : @core.TerminalBuffer) -> Unit {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height

  // Fill background
  buffer.fill_rect(
    x,
    y,
    width,
    height,
    ' ',
    self.base.foreground_color,
    self.base.background_color,
    @core.TextStyle::None,
  )

  // Render border
  self.render_border(buffer)
}

///|
pub fn Box::with_border_style(self : Box, style : @core.BorderStyle) -> Box {
  { ..self, border_style: style }
}

///|
pub fn Box::with_border_color(self : Box, color : @core.RGBA) -> Box {
  { ..self, border_color: color }
}

///|
pub fn Box::with_title(self : Box, title : String) -> Box {
  { ..self, title: Some(title) }
}

///|
pub fn Box::with_title_alignment(self : Box, align : @core.TextAlign) -> Box {
  { ..self, title_align: align }
}

///|
pub fn Box::with_padding(self : Box, padding : Int) -> Box {
  { ..self, padding }
}

///|
pub fn Box::with_background_color(self : Box, color : @core.RGBA) -> Box {
  { ..self, base: { ..self.base, background_color: color } }
}

///|
pub fn Box::with_foreground_color(self : Box, color : @core.RGBA) -> Box {
  { ..self, base: { ..self.base, foreground_color: color } }
}

// Delegating methods for helpers compatibility
pub fn Box::set_width(self : Box, width : Int) -> Unit {
  self.base.width = width
}

pub fn Box::set_height(self : Box, height : Int) -> Unit {
  self.base.height = height
}

///|
/// Add a child to this box's base renderable
pub fn Box::add_child(self : Box, child : @core.BaseRenderable) -> Box {
  self.base.add_child(child)
  self
}

///|
fn get_border_chars(self : Box) -> (Char, Char, Char, Char, Char, Char) {
  match self.border_style {
    @core.BorderStyle::None => (' ', ' ', ' ', ' ', ' ', ' ')
    @core.BorderStyle::Single => ('─', '│', '┌', '┐', '└', '┘')
    @core.BorderStyle::Double => ('═', '║', '╔', '╗', '╚', '╝')
    @core.BorderStyle::Thick => ('━', '┃', '┏', '┓', '┗', '┛')
    @core.BorderStyle::Rounded => ('─', '│', '╭', '╮', '╰', '╯')
    @core.BorderStyle::Dashed => ('┄', '┆', '┌', '┐', '└', '┘')
    @core.BorderStyle::Dotted => ('┈', '┊', '┌', '┐', '└', '┘')
  }
}

///|
pub fn Box::calculate_content_area(self : Box) -> @core.Rect {
  let border_width = if self.border_style == @core.BorderStyle::None {
    0
  } else {
    1
  }
  let title_height = match self.title {
    Some(_) => 1
    None => 0
  }
  let content_x = self.base.absolute_x() + border_width + self.padding
  let content_y = self.base.absolute_y() + border_width + self.padding + title_height
  let content_width = self.base.width - (border_width + self.padding) * 2
  let content_height = self.base.height -
    (border_width + self.padding) * 2 -
    title_height
  let final_width = if content_width > 0 { content_width } else { 0 }
  let final_height = if content_height > 0 { content_height } else { 0 }
  @core.Rect::new(content_x, content_y, final_width, final_height)
}

///|
fn render_border(self : Box, buffer : @core.TerminalBuffer) -> Unit {
  if self.border_style == @core.BorderStyle::None {
    return
  }
  let (h_line, v_line, top_left, top_right, bottom_left, bottom_right) = self.get_border_chars()
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height

  // Corners
  buffer.write_char(
    x,
    y,
    top_left,
    self.border_color,
    self.base.background_color,
    @core.TextStyle::None,
  )
  buffer.write_char(
    x + width - 1,
    y,
    top_right,
    self.border_color,
    self.base.background_color,
    @core.TextStyle::None,
  )
  buffer.write_char(
    x,
    y + height - 1,
    bottom_left,
    self.border_color,
    self.base.background_color,
    @core.TextStyle::None,
  )
  buffer.write_char(
    x + width - 1,
    y + height - 1,
    bottom_right,
    self.border_color,
    self.base.background_color,
    @core.TextStyle::None,
  )

  // Horizontal lines
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_char(
      x + i,
      y,
      h_line,
      self.border_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
    buffer.write_char(
      x + i,
      y + height - 1,
      h_line,
      self.border_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }

  // Vertical lines
  for i = 1; i < height - 1; i = i + 1 {
    buffer.write_char(
      x,
      y + i,
      v_line,
      self.border_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
    buffer.write_char(
      x + width - 1,
      y + i,
      v_line,
      self.border_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }

  // Title
  match self.title {
    Some(title) => {
      let title_x = match self.title_align {
        @core.TextAlign::Left => x + 2
        @core.TextAlign::Center => x + width / 2 - title.length() / 2
        @core.TextAlign::Right => x + width - title.length() - 2
      }
      if title_x >= x + 1 && title_x + title.length() <= x + width - 1 {
        buffer.write_string(
          title_x,
          y,
          title,
          self.border_color,
          self.base.background_color,
          @core.TextStyle::None,
        )
      }
    }
    None => ()
  }
}

/// Helper to set dimensions
pub fn Box::with_dimensions(self : Box, x : Int, y : Int, width : Int, height : Int) -> Box {
  { ..self, base: { ..self.base, x, y, width, height } }
}