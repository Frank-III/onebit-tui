///|
/// Text component using BaseRenderable architecture

///|
/// Text component for displaying styled text content
pub struct Text {
  mut base : @core.BaseRenderable
  content : String
  style : @core.TextStyle
  wrap : @core.TextWrap
  align : @core.TextAlign
}

///|
pub fn Text::new(id : String, content : String) -> Text {
  {
    base: @core.BaseRenderable::new(id),
    content,
    style: @core.TextStyle::None,
    wrap: @core.TextWrap::None,
    align: @core.TextAlign::Left,
  }
}

///|
/// Get the base renderable
pub fn Text::as_renderable(self : Text) -> @core.BaseRenderable {
  // Set up the render function if not already set
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      self.render_text(buffer)
    })
  }
  self.base
}

///|
/// Render this text content
fn render_text(self : Text, buffer : @core.TerminalBuffer) -> Unit {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height

  // First fill background if needed
  if self.base.background_color != @core.RGBA::black() {
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
  }

  // Get lines based on wrapping mode
  let lines = match self.wrap {
    @core.TextWrap::None => self.split_lines_no_wrap()
    @core.TextWrap::Word => self.split_lines_word_wrap(width)
    @core.TextWrap::Character => self.split_lines_char_wrap(width)
  }

  // Render each line with alignment
  let mut current_y = y
  for i = 0; i < lines.length() && current_y < y + height; i = i + 1 {
    let line = lines[i]
    if line.length() > 0 {
      let line_x = match self.align {
        @core.TextAlign::Left => x
        @core.TextAlign::Center => x + (width - line.length()) / 2
        @core.TextAlign::Right => x + width - line.length()
      }
      
      buffer.write_string(
        line_x,
        current_y,
        line,
        self.base.foreground_color,
        self.base.background_color,
        self.style,
      )
    }
    current_y = current_y + 1
  }
}

///|
pub fn Text::with_content(self : Text, content : String) -> Text {
  { ..self, content }
}

///|
pub fn Text::with_style(self : Text, style : @core.TextStyle) -> Text {
  { ..self, style }
}

///|
pub fn Text::with_wrap(self : Text, wrap : @core.TextWrap) -> Text {
  { ..self, wrap }
}

///|
pub fn Text::with_align(self : Text, align : @core.TextAlign) -> Text {
  { ..self, align }
}

///|
pub fn Text::with_foreground_color(self : Text, color : @core.RGBA) -> Text {
  { ..self, base: { ..self.base, foreground_color: color } }
}

///|
pub fn Text::with_background_color(self : Text, color : @core.RGBA) -> Text {
  { ..self, base: { ..self.base, background_color: color } }
}

///| Split content into lines without wrapping
fn split_lines_no_wrap(self : Text) -> Array[String] {
  let lines = []
  let mut current_line = ""
  
  for i = 0; i < self.content.length(); i = i + 1 {
    let ch = self.content[i]
    if ch == '\n' {
      lines.push(current_line)
      current_line = ""
    } else {
      current_line = current_line + ch.to_string()
    }
  }
  
  if current_line.length() > 0 {
    lines.push(current_line)
  }
  
  lines
}

///| Split content into lines with word wrapping
fn split_lines_word_wrap(self : Text, max_width : Int) -> Array[String] {
  if max_width <= 0 {
    return []
  }
  
  let lines = []
  let words = self.split_into_words()
  let mut current_line = ""
  
  for word in words {
    if word == "\n" {
      lines.push(current_line)
      current_line = ""
    } else if current_line.length() == 0 {
      current_line = word
    } else if current_line.length() + 1 + word.length() <= max_width {
      current_line = current_line + " " + word
    } else {
      lines.push(current_line)
      current_line = word
    }
  }
  
  if current_line.length() > 0 {
    lines.push(current_line)
  }
  
  lines
}

///| Split content into lines with character wrapping
fn split_lines_char_wrap(self : Text, max_width : Int) -> Array[String] {
  if max_width <= 0 {
    return []
  }
  
  let lines = []
  let mut current_line = ""
  
  for i = 0; i < self.content.length(); i = i + 1 {
    let ch = self.content[i]
    if ch == '\n' {
      lines.push(current_line)
      current_line = ""
    } else if current_line.length() >= max_width {
      lines.push(current_line)
      current_line = ch.to_string()
    } else {
      current_line = current_line + ch.to_string()
    }
  }
  
  if current_line.length() > 0 {
    lines.push(current_line)
  }
  
  lines
}

///| Split content into words for word wrapping
fn split_into_words(self : Text) -> Array[String] {
  let words = []
  let mut current_word = ""
  
  for i = 0; i < self.content.length(); i = i + 1 {
    let ch = self.content[i]
    if ch == ' ' || ch == '\t' {
      if current_word.length() > 0 {
        words.push(current_word)
        current_word = ""
      }
    } else if ch == '\n' {
      if current_word.length() > 0 {
        words.push(current_word)
        current_word = ""
      }
      words.push("\n")
    } else {
      current_word = current_word + ch.to_string()
    }
  }
  
  if current_word.length() > 0 {
    words.push(current_word)
  }
  
  words
}

/// Helper to set dimensions
pub fn Text::with_dimensions(self : Text, x : Int, y : Int, width : Int, height : Int) -> Text {
  { ..self, base: { ..self.base, x, y, width, height } }
}

/// Add a child to this text's base renderable
pub fn Text::add_child(self : Text, child : @core.BaseRenderable) -> Text {
  self.base.add_child(child)
  self
}