///|
/// TextInput Component
/// Provides text editing capabilities with cursor movement and selection

pub struct TextInput {
  id : String
  mut bounds : @core.Rect
  mut visible : Bool
  mut focused : Bool
  
  // Text state
  mut value : String
  mut cursor_position : Int
  mut selection_start : Option[Int]
  mut selection_end : Option[Int]
  mut scroll_offset : Int
  
  // Configuration
  mut placeholder : String
  mut max_length : Option[Int]
  mut password_mode : Bool
  password_char : Char
  
  // Styling
  background_color : @core.RGBA
  text_color : @core.RGBA
  placeholder_color : @core.RGBA
  cursor_color : @core.RGBA
  selection_color : @core.RGBA
  border_style : @core.BorderStyle
  border_color : @core.RGBA
  focused_border_color : @core.RGBA
  
  // Callbacks
  mut on_change : Option[(String) -> Unit]
  mut on_submit : Option[(String) -> Unit]
  mut on_focus : Option[() -> Unit]
  mut on_blur : Option[() -> Unit]
  
  // Edit history for undo/redo
  mut history : Array[TextInputHistoryEntry]
  mut history_index : Int
}

struct TextInputHistoryEntry {
  value : String
  cursor_position : Int
}

pub fn TextInput::new(id : String) -> TextInput {
  {
    id,
    bounds: @core.Rect::new(0, 0, 20, 1),
    visible: true,
    focused: false,
    value: "",
    cursor_position: 0,
    selection_start: None,
    selection_end: None,
    scroll_offset: 0,
    placeholder: "",
    max_length: None,
    password_mode: false,
    password_char: '•',
    background_color: @core.RGBA::black(),
    text_color: @core.RGBA::white(),
    placeholder_color: @core.RGBA::gray(),
    cursor_color: @core.RGBA::white(),
    selection_color: @core.RGBA::rgb(0.2, 0.4, 0.8),
    border_style: @core.BorderStyle::Single,
    border_color: @core.RGBA::gray(),
    focused_border_color: @core.RGBA::white(),
    on_change: None,
    on_submit: None,
    on_focus: None,
    on_blur: None,
    history: [],
    history_index: 0
  }
}

pub fn TextInput::set_bounds(self : TextInput, x : Int, y : Int, width : Int, height : Int) -> Unit {
  self.bounds = @core.Rect::new(x, y, width, height)
}

pub fn TextInput::set_value(self : TextInput, value : String) -> Unit {
  match self.max_length {
    Some(max_len) => {
      if value.length() > max_len {
        self.value = @core.string_substring(value, 0, max_len)
      } else {
        self.value = value
      }
    }
    None => self.value = value
  }
  self.cursor_position = self.value.length()
  self.clear_selection()
  self.add_to_history()
  self.trigger_change()
}

pub fn TextInput::focus(self : TextInput) -> Unit {
  self.focused = true
  match self.on_focus {
    Some(cb) => cb()
    None => ()
  }
}

pub fn TextInput::blur(self : TextInput) -> Unit {
  self.focused = false
  self.clear_selection()
  match self.on_blur {
    Some(cb) => cb()
    None => ()
  }
}

// Text editing operations
pub fn TextInput::insert_char(self : TextInput, char : Char) -> Unit {
  if self.has_selection() {
    self.delete_selection()
  }
  
  // Check max length
  match self.max_length {
    Some(max_len) => {
      if self.value.length() >= max_len {
        return
      }
    }
    None => ()
  }
  
  // Insert character at cursor position
  let before = @core.string_substring(self.value, 0, self.cursor_position)
  let after = @core.string_substring(self.value, self.cursor_position, self.value.length())
  self.value = before + char.to_string() + after
  self.cursor_position = self.cursor_position + 1
  
  self.add_to_history()
  self.trigger_change()
}

pub fn TextInput::delete_char_before(self : TextInput) -> Unit {
  if self.has_selection() {
    self.delete_selection()
    return
  }
  
  if self.cursor_position > 0 {
    let before = @core.string_substring(self.value, 0, self.cursor_position - 1)
    let after = @core.string_substring(self.value, self.cursor_position, self.value.length())
    self.value = before + after
    self.cursor_position = self.cursor_position - 1
    
    self.add_to_history()
    self.trigger_change()
  }
}

pub fn TextInput::delete_char_after(self : TextInput) -> Unit {
  if self.has_selection() {
    self.delete_selection()
    return
  }
  
  if self.cursor_position < self.value.length() {
    let before = @core.string_substring(self.value, 0, self.cursor_position)
    let after = @core.string_substring(self.value, self.cursor_position + 1, self.value.length())
    self.value = before + after
    
    self.add_to_history()
    self.trigger_change()
  }
}

// Cursor movement
pub fn TextInput::move_cursor_left(self : TextInput) -> Unit {
  if self.cursor_position > 0 {
    self.cursor_position = self.cursor_position - 1
    self.clear_selection()
  }
}

pub fn TextInput::move_cursor_right(self : TextInput) -> Unit {
  if self.cursor_position < self.value.length() {
    self.cursor_position = self.cursor_position + 1
    self.clear_selection()
  }
}

pub fn TextInput::move_cursor_to_start(self : TextInput) -> Unit {
  self.cursor_position = 0
  self.clear_selection()
}

pub fn TextInput::move_cursor_to_end(self : TextInput) -> Unit {
  self.cursor_position = self.value.length()
  self.clear_selection()
}

pub fn TextInput::move_cursor_word_left(self : TextInput) -> Unit {
  if self.cursor_position == 0 {
    return
  }
  
  // Skip spaces
  while self.cursor_position > 0 && self.value[self.cursor_position - 1] == ' ' {
    self.cursor_position = self.cursor_position - 1
  }
  
  // Skip word characters
  while self.cursor_position > 0 && self.value[self.cursor_position - 1] != ' ' {
    self.cursor_position = self.cursor_position - 1
  }
  
  self.clear_selection()
}

pub fn TextInput::move_cursor_word_right(self : TextInput) -> Unit {
  if self.cursor_position >= self.value.length() {
    return
  }
  
  // Skip word characters
  while self.cursor_position < self.value.length() && self.value[self.cursor_position] != ' ' {
    self.cursor_position = self.cursor_position + 1
  }
  
  // Skip spaces
  while self.cursor_position < self.value.length() && self.value[self.cursor_position] == ' ' {
    self.cursor_position = self.cursor_position + 1
  }
  
  self.clear_selection()
}

// Selection
pub fn TextInput::select_all(self : TextInput) -> Unit {
  self.selection_start = Some(0)
  self.selection_end = Some(self.value.length())
  self.cursor_position = self.value.length()
}

pub fn TextInput::has_selection(self : TextInput) -> Bool {
  match (self.selection_start, self.selection_end) {
    (Some(_), Some(_)) => true
    _ => false
  }
}

pub fn TextInput::clear_selection(self : TextInput) -> Unit {
  self.selection_start = None
  self.selection_end = None
}

pub fn TextInput::get_selection_range(self : TextInput) -> (Int, Int) {
  match (self.selection_start, self.selection_end) {
    (Some(start), Some(end)) => {
      if start < end {
        (start, end)
      } else {
        (end, start)
      }
    }
    _ => (0, 0)
  }
}

pub fn TextInput::delete_selection(self : TextInput) -> Unit {
  if not(self.has_selection()) {
    return
  }
  
  let (start, end) = self.get_selection_range()
  let before = @core.string_substring(self.value, 0, start)
  let after = @core.string_substring(self.value, end, self.value.length())
  self.value = before + after
  self.cursor_position = start
  self.clear_selection()
  
  self.add_to_history()
  self.trigger_change()
}

// Undo/Redo
pub fn TextInput::undo(self : TextInput) -> Unit {
  if self.history_index > 0 {
    self.history_index = self.history_index - 1
    let entry = self.history[self.history_index]
    self.value = entry.value
    self.cursor_position = entry.cursor_position
    self.clear_selection()
    self.trigger_change()
  }
}

pub fn TextInput::redo(self : TextInput) -> Unit {
  if self.history_index < self.history.length() - 1 {
    self.history_index = self.history_index + 1
    let entry = self.history[self.history_index]
    self.value = entry.value
    self.cursor_position = entry.cursor_position
    self.clear_selection()
    self.trigger_change()
  }
}

fn TextInput::add_to_history(self : TextInput) -> Unit {
  // Remove any history after current index
  while self.history.length() > self.history_index + 1 {
    let _ = self.history.pop()
  }
  
  // Add new entry
  self.history.push({
    value: self.value,
    cursor_position: self.cursor_position
  })
  self.history_index = self.history.length() - 1
  
  // Limit history size
  if self.history.length() > 100 {
    let _ = self.history.remove(0)
    self.history_index = self.history_index - 1
  }
}

fn TextInput::trigger_change(self : TextInput) -> Unit {
  match self.on_change {
    Some(cb) => cb(self.value)
    None => ()
  }
}

pub fn TextInput::submit(self : TextInput) -> Unit {
  match self.on_submit {
    Some(cb) => cb(self.value)
    None => ()
  }
}

// Rendering
pub fn TextInput::render(self : TextInput, buffer : @core.TerminalBuffer) -> Unit {
  if not(self.visible) {
    return
  }
  
  let has_border = self.border_style != @core.BorderStyle::None
  let border_offset = if has_border { 1 } else { 0 }
  let content_x = self.bounds.x + border_offset
  let content_y = self.bounds.y + border_offset
  let content_width = self.bounds.width - 2 * border_offset
  
  // Draw border
  if has_border {
    let border_color = if self.focused { self.focused_border_color } else { self.border_color }
    draw_input_border(
      buffer,
      self.bounds.x,
      self.bounds.y,
      self.bounds.width,
      self.bounds.height,
      self.border_style,
      border_color,
      self.background_color
    )
  }
  
  // Clear content area
  buffer.fill_rect(
    content_x,
    content_y,
    content_width,
    1,
    ' ',
    self.text_color,
    self.background_color,
    @core.TextStyle::None
  )
  
  // Determine visible text
  let display_text = if self.password_mode {
    let mut pwd_text = ""
    for i = 0; i < self.value.length(); i = i + 1 {
      pwd_text = pwd_text + self.password_char.to_string()
    }
    pwd_text
  } else {
    self.value
  }
  
  // Calculate scroll offset
  if self.cursor_position < self.scroll_offset {
    self.scroll_offset = self.cursor_position
  } else if self.cursor_position > self.scroll_offset + content_width - 1 {
    self.scroll_offset = self.cursor_position - content_width + 1
  }
  
  // Show placeholder or text
  if self.value.length() == 0 && not(self.focused) {
    buffer.write_string(
      content_x,
      content_y,
      @core.string_substring(self.placeholder, 0, min(self.placeholder.length(), content_width)),
      self.placeholder_color,
      self.background_color,
      @core.TextStyle::Italic
    )
  } else {
    // Render visible portion of text
    let visible_start = self.scroll_offset
    let visible_end = min(display_text.length(), self.scroll_offset + content_width)
    
    for i = visible_start; i < visible_end; i = i + 1 {
      let char_x = content_x + i - visible_start
      let is_selected = self.has_selection() && {
        let (sel_start, sel_end) = self.get_selection_range()
        i >= sel_start && i < sel_end
      }
      
      let bg_color = if is_selected { self.selection_color } else { self.background_color }
      let char = display_text[i].to_char().unwrap()
      
      buffer.write_char(
        char_x,
        content_y,
        char,
        self.text_color,
        bg_color,
        @core.TextStyle::None
      )
    }
    
    // Draw cursor
    if self.focused {
      let cursor_x = content_x + self.cursor_position - self.scroll_offset
      if cursor_x >= content_x && cursor_x < content_x + content_width {
        let cursor_char = if self.cursor_position < display_text.length() {
          display_text[self.cursor_position].to_char().unwrap()
        } else {
          ' '
        }
        
        buffer.write_char(
          cursor_x,
          content_y,
          cursor_char,
          self.background_color,
          self.cursor_color,
          @core.TextStyle::None
        )
      }
    }
  }
}

fn draw_input_border(
  buffer : @core.TerminalBuffer,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  style : @core.BorderStyle,
  fg : @core.RGBA,
  bg : @core.RGBA
) -> Unit {
  let chars = match style {
    @core.BorderStyle::Single => ('─', '│', '┌', '┐', '└', '┘')
    @core.BorderStyle::Double => ('═', '║', '╔', '╗', '╚', '╝')
    @core.BorderStyle::Thick => ('━', '┃', '┏', '┓', '┗', '┛')
    @core.BorderStyle::Rounded => ('─', '│', '╭', '╮', '╰', '╯')
    _ => return
  }
  
  let (h_line, v_line, tl, tr, bl, br) = chars
  
  // For single-line input, only draw if height > 1
  if height > 1 {
    // Full border
    buffer.write_char(x, y, tl, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + width - 1, y, tr, fg, bg, @core.TextStyle::None)
    buffer.write_char(x, y + height - 1, bl, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + width - 1, y + height - 1, br, fg, bg, @core.TextStyle::None)
    
    for i = 1; i < width - 1; i = i + 1 {
      buffer.write_char(x + i, y, h_line, fg, bg, @core.TextStyle::None)
      buffer.write_char(x + i, y + height - 1, h_line, fg, bg, @core.TextStyle::None)
    }
    
    for i = 1; i < height - 1; i = i + 1 {
      buffer.write_char(x, y + i, v_line, fg, bg, @core.TextStyle::None)
      buffer.write_char(x + width - 1, y + i, v_line, fg, bg, @core.TextStyle::None)
    }
  } else {
    // Just side borders for single-line input
    buffer.write_char(x, y, v_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + width - 1, y, v_line, fg, bg, @core.TextStyle::None)
  }
}

fn min(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}

// Builder pattern
pub struct TextInputBuilder {
  id : String
  mut x : Int
  mut y : Int
  mut width : Int
  mut placeholder : String
  mut password_mode : Bool
  mut max_length : Option[Int]
  mut value : String
  mut on_change : Option[(String) -> Unit]
  mut on_submit : Option[(String) -> Unit]
}

pub fn TextInput::builder(id : String) -> TextInputBuilder {
  {
    id,
    x: 0,
    y: 0,
    width: 20,
    placeholder: "",
    password_mode: false,
    max_length: None,
    value: "",
    on_change: None,
    on_submit: None
  }
}

pub fn TextInputBuilder::position(self : TextInputBuilder, x : Int, y : Int) -> TextInputBuilder {
  self.x = x
  self.y = y
  self
}

pub fn TextInputBuilder::width(self : TextInputBuilder, width : Int) -> TextInputBuilder {
  self.width = width
  self
}

pub fn TextInputBuilder::placeholder(self : TextInputBuilder, text : String) -> TextInputBuilder {
  self.placeholder = text
  self
}

pub fn TextInputBuilder::password(self : TextInputBuilder) -> TextInputBuilder {
  self.password_mode = true
  self
}

pub fn TextInputBuilder::max_length(self : TextInputBuilder, length : Int) -> TextInputBuilder {
  self.max_length = Some(length)
  self
}

pub fn TextInputBuilder::value(self : TextInputBuilder, value : String) -> TextInputBuilder {
  self.value = value
  self
}

pub fn TextInputBuilder::on_change(self : TextInputBuilder, handler : (String) -> Unit) -> TextInputBuilder {
  self.on_change = Some(handler)
  self
}

pub fn TextInputBuilder::on_submit(self : TextInputBuilder, handler : (String) -> Unit) -> TextInputBuilder {
  self.on_submit = Some(handler)
  self
}

pub fn TextInputBuilder::build(self : TextInputBuilder) -> TextInput {
  let input = TextInput::new(self.id)
  input.set_bounds(self.x, self.y, self.width, 3) // Height 3 for border
  input.placeholder = self.placeholder
  input.password_mode = self.password_mode
  input.max_length = self.max_length
  if self.value.length() > 0 {
    input.set_value(self.value)
  }
  input.on_change = self.on_change
  input.on_submit = self.on_submit
  input
}