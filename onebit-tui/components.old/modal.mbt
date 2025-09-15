///|
/// Modal Dialog Component
/// Provides modal overlay dialogs with customizable content

pub struct Modal {
  base : @core.BaseRenderable
  title : String
  mut content : Array[String]
  buttons : Array[ModalButton]
  mut selected_button : Int
  
  // Styling
  mut border_style : @core.BorderStyle
  overlay_color : @core.RGBA
  button_color : @core.RGBA
  button_selected_color : @core.RGBA
  
  // Callbacks
  on_close : Option[() -> Unit]
}

pub struct ModalButton {
  text : String
  action : () -> Unit
  is_default : Bool
}

pub fn Modal::new(id : String, title : String) -> Modal {
  let modal = {
    base: @core.BaseRenderable::new(id),
    title,
    content: [],
    buttons: [],
    selected_button: 0,
    border_style: @core.BorderStyle::Double,
    overlay_color: @core.RGBA::{ r: 0.0, g: 0.0, b: 0.0, a: 0.7 },
    button_color: @core.RGBA::rgb(0.2, 0.2, 0.2),
    button_selected_color: @core.RGBA::blue(),
    on_close: None
  }
  
  // Set default size and center position
  modal.base.width = 40
  modal.base.height = 10
  modal.base.visible = false
  modal.base.background_color = @core.RGBA::rgb(0.1, 0.1, 0.1)
  modal.base.foreground_color = @core.RGBA::white()
  
  // Set the render function
  modal.base.set_render_fn(fn(_base, buffer) {
    modal.render(buffer)
  })
  
  modal
}

/// Get the base renderable
pub fn Modal::as_renderable(self : Modal) -> @core.BaseRenderable {
  self.base
}

pub fn Modal::show(self : Modal) -> Unit {
  self.base.visible = true
}

pub fn Modal::hide(self : Modal) -> Unit {
  self.base.visible = false
  match self.on_close {
    Some(cb) => cb()
    None => ()
  }
}

pub fn Modal::set_content(self : Modal, lines : Array[String]) -> Unit {
  self.content = lines
  // Auto-size height based on content
  let content_height = lines.length() + 4 // title + buttons + padding
  if content_height > self.base.height {
    self.base.height = content_height
  }
}

pub fn Modal::add_button(self : Modal, text : String, action : () -> Unit, is_default? : Bool = false) -> Unit {
  self.buttons.push({ text, action, is_default })
  if is_default {
    // Find the index of this button
    for i = 0; i < self.buttons.length(); i = i + 1 {
      if self.buttons[i].is_default {
        self.selected_button = i
        break
      }
    }
  }
}

pub fn Modal::select_next_button(self : Modal) -> Unit {
  if self.selected_button < self.buttons.length() - 1 {
    self.selected_button = self.selected_button + 1
  }
}

pub fn Modal::select_previous_button(self : Modal) -> Unit {
  if self.selected_button > 0 {
    self.selected_button = self.selected_button - 1
  }
}

pub fn Modal::activate_selected_button(self : Modal) -> Unit {
  if self.selected_button >= 0 && self.selected_button < self.buttons.length() {
    let button = self.buttons[self.selected_button]
    (button.action)()
  }
}

pub fn Modal::render(self : Modal, buffer : @core.TerminalBuffer) -> Unit {
  if not(self.base.visible) {
    return
  }
  
  // Get screen dimensions from buffer
  let screen_width = buffer.width()
  let screen_height = buffer.height()
  
  // Calculate modal position (centered)
  self.base.x = screen_width / 2 - self.base.width / 2
  self.base.y = screen_height / 2 - self.base.height / 2
  
  // Draw overlay
  for y = 0; y < screen_height; y = y + 1 {
    for x = 0; x < screen_width; x = x + 1 {
      // Get existing cell to blend with overlay
      match buffer.get_cell(x, y) {
        Some(cell) => {
          // Darken the background
          let darkened_bg = @core.RGBA::{
            r: cell.bg_color.r * 0.3,
            g: cell.bg_color.g * 0.3,
            b: cell.bg_color.b * 0.3,
            a: 1.0
          }
          buffer.write_char(x, y, cell.char, cell.fg_color, darkened_bg, cell.style)
        }
        None => ()
      }
    }
  }
  
  // Modal should be centered on screen, not relative to its parent
  let modal_x = (screen_width - self.base.width) / 2
  let modal_y = (screen_height - self.base.height) / 2
  
  // Draw modal background
  buffer.fill_rect(
    modal_x,
    modal_y,
    self.base.width,
    self.base.height,
    ' ',
    self.base.foreground_color,
    self.base.background_color,
    @core.TextStyle::None
  )
  
  // Draw border
  draw_modal_border(
    buffer,
    modal_x,
    modal_y,
    self.base.width,
    self.base.height,
    self.border_style,
    self.base.foreground_color,
    self.base.background_color
  )
  
  // Draw title
  let title_x = modal_x + self.base.width / 2 - self.title.length() / 2
  buffer.write_string(
    title_x,
    modal_y + 1,
    self.title,
    self.base.foreground_color,
    self.base.background_color,
    @core.TextStyle::Bold
  )
  
  // Draw title separator
  for i = modal_x + 1; i < modal_x + self.base.width - 1; i = i + 1 {
    buffer.write_char(i, modal_y + 2, '─', self.base.foreground_color, self.base.background_color, @core.TextStyle::None)
  }
  
  // Draw content
  let content_y = modal_y + 3
  for i = 0; i < self.content.length(); i = i + 1 {
    let line = self.content[i]
    let text_x = modal_x + 2
    
    // Wrap text if too long
    if line.length() > self.base.width - 4 {
      buffer.write_string(
        text_x,
        content_y + i,
        @core.string_substring(line, 0, self.base.width - 7) + "...",
        self.base.foreground_color,
        self.base.background_color,
        @core.TextStyle::None
      )
    } else {
      buffer.write_string(
        text_x,
        content_y + i,
        line,
        self.base.foreground_color,
        self.base.background_color,
        @core.TextStyle::None
      )
    }
  }
  
  // Draw buttons
  if self.buttons.length() > 0 {
    let button_y = modal_y + self.base.height - 2
    let total_button_width = self.buttons.fold(
      init=0,
      fn(acc, button) { acc + button.text.length() + 4 }
    )
    let button_x = modal_x + self.base.width / 2 - total_button_width / 2
    
    let mut current_x = button_x
    for i = 0; i < self.buttons.length(); i = i + 1 {
      let button = self.buttons[i]
      let is_selected = i == self.selected_button
      
      // Button background
      let bg_color = if is_selected { self.button_selected_color } else { self.button_color }
      let text_style = if is_selected { @core.TextStyle::Bold } else { @core.TextStyle::None }
      
      // Draw button
      let button_text = " " + button.text + " "
      buffer.fill_rect(
        current_x,
        button_y,
        button_text.length(),
        1,
        ' ',
        self.base.foreground_color,
        bg_color,
        text_style
      )
      
      buffer.write_string(
        current_x,
        button_y,
        button_text,
        self.base.foreground_color,
        bg_color,
        text_style
      )
      
      current_x = current_x + button_text.length() + 1
    }
  }
}

fn draw_modal_border(
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
  
  // Corners
  buffer.write_char(x, y, tl, fg, bg, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y, tr, fg, bg, @core.TextStyle::None)
  buffer.write_char(x, y + height - 1, bl, fg, bg, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y + height - 1, br, fg, bg, @core.TextStyle::None)
  
  // Lines
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_char(x + i, y, h_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + i, y + height - 1, h_line, fg, bg, @core.TextStyle::None)
  }
  
  for i = 1; i < height - 1; i = i + 1 {
    buffer.write_char(x, y + i, v_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + width - 1, y + i, v_line, fg, bg, @core.TextStyle::None)
  }
}

///| Builder pattern for Modal
pub struct ModalBuilder {
  id : String
  title : String
  mut content : Array[String]
  mut buttons : Array[ModalButton]
  mut width : Int
  mut height : Int
  mut border_style : @core.BorderStyle
}

pub fn Modal::builder(id : String, title : String) -> ModalBuilder {
  {
    id,
    title,
    content: [],
    buttons: [],
    width: 40,
    height: 10,
    border_style: @core.BorderStyle::Double
  }
}

pub fn ModalBuilder::content(self : ModalBuilder, lines : Array[String]) -> ModalBuilder {
  self.content = lines
  self
}

pub fn ModalBuilder::add_line(self : ModalBuilder, text : String) -> ModalBuilder {
  self.content.push(text)
  self
}

pub fn ModalBuilder::size(self : ModalBuilder, width : Int, height : Int) -> ModalBuilder {
  self.width = width
  self.height = height
  self
}

pub fn ModalBuilder::border(self : ModalBuilder, style : @core.BorderStyle) -> ModalBuilder {
  self.border_style = style
  self
}

pub fn ModalBuilder::button(self : ModalBuilder, text : String, action : () -> Unit, is_default? : Bool = false) -> ModalBuilder {
  self.buttons.push({ text, action, is_default })
  self
}

pub fn ModalBuilder::build(self : ModalBuilder) -> Modal {
  let modal = Modal::new(self.id, self.title)
  modal.set_content(self.content)
  modal.base.width = self.width
  modal.base.height = self.height
  modal.border_style = self.border_style
  
  for i = 0; i < self.buttons.length(); i = i + 1 {
    let button = self.buttons[i]
    modal.add_button(button.text, button.action, is_default=button.is_default)
  }
  
  modal
}

///| Alert modal helper
pub fn alert(title : String, message : String, on_ok : () -> Unit) -> Modal {
  Modal::builder("alert", title)
    .add_line(message)
    .button("OK", on_ok, is_default=true)
    .build()
}

///| Confirm modal helper
pub fn confirm(title : String, message : String, on_yes : () -> Unit, on_no : () -> Unit) -> Modal {
  Modal::builder("confirm", title)
    .add_line(message)
    .button("Yes", on_yes)
    .button("No", on_no, is_default=true)
    .build()
}