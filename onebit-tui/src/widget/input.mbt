///|
/// TextInput widget - for text entry
pub struct TextInput {
  value : Ref[String]
  mut placeholder : String
  mut width : Double
  style : InputStyle
  mut id : Int?
}

///|
pub struct InputStyle {
  border : @view.BorderStyle
  border_color : @core.Color
  text_color : @core.Color
  placeholder_color : @core.Color
}

///|
/// Create a new text input
pub fn TextInput::new(value : Ref[String]) -> TextInput {
  {
    value,
    placeholder: "Type here...",
    width: 30.0,
    style: InputStyle::default(),
    id: None,
  }
}

///|
/// Set placeholder text
pub fn TextInput::placeholder(self : TextInput, text : String) -> TextInput {
  self.placeholder = text
  self
}

///|
/// Set width
pub fn TextInput::width(self : TextInput, w : Double) -> TextInput {
  self.width = w
  self
}

///|
/// Assign a stable ID for focus/dispatch across rebuilds
pub fn TextInput::with_id(self : TextInput, id : Int) -> TextInput {
  self.id = Some(id)
  self
}

// Input styles

///|
pub fn InputStyle::default() -> InputStyle {
  {
    border: @view.BorderStyle::Single,
    border_color: @core.Color::Gray,
    text_color: @core.Color::White,
    placeholder_color: @core.Color::Gray,
  }
}

// Implement Component trait

///|
pub impl @view.Component for TextInput with render(self) {
  let display_text = if self.value.val == "" {
    self.placeholder
  } else {
    self.value.val
  }
  let text_color = if self.value.val == "" {
    self.style.placeholder_color
  } else {
    self.style.text_color
  }
  let mut view = @view.View::text(display_text, color=text_color)
    .width(self.width)
    .padding(1.0)
    .height(3.0)
    .border(self.style.border)
    .focused_border_color(@core.Color::Cyan)
    .focusable()
    .on_key(fn(key) {
      match key {
        @ffi.KeyEvent::Char(c) => {
          self.value.val = self.value.val + c.to_char().unwrap_or(' ').to_string()
          true
        }
        @ffi.KeyEvent::Backspace => {
          if self.value.val.length() > 0 {
            let len = self.value.val.length()
            let chars : Array[Char] = []
            for i = 0; i < len - 1; i = i + 1 {
              match self.value.val.get_char(i) {
                Some(c) => chars.push(c)
                None => ()
              }
            }
            self.value.val = String::from_array(chars)
          }
          true
        }
        _ => false
      }
    })
  // Apply stable id if provided
  match self.id {
    Some(i) => view = view.id(i)
    None => ()
  }
  view
}

///|
pub impl @view.Component for TextInput with handle_event(self, event) {
  match event {
    @events.Event::Key(key) =>
      match key {
        @ffi.KeyEvent::Char(c) => {
          self.value.val = self.value.val + c.to_char().unwrap_or(' ').to_string()
          true
        }
        @ffi.KeyEvent::Backspace => {
          if self.value.val.length() > 0 {
            let len = self.value.val.length()
            let chars : Array[Char] = []
            for i = 0; i < len - 1; i = i + 1 {
              match self.value.val.get_char(i) {
                Some(c) => chars.push(c)
                None => ()
              }
            }
            self.value.val = String::from_array(chars)
          }
          true
        }
        _ => false
      }
    _ => false
  }
}

///|
pub impl @view.Component for TextInput with is_focusable(self) {
  true
}
