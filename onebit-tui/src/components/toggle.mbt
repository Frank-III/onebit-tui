pub(all) struct Toggle {
  mut checked : Bool
  mut focused : Bool
  mut disabled : Bool
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  mut on_change : Option[(Bool) -> Unit]
  label : String
}

pub fn Toggle::new(
  ~checked : Bool = false,
  ~disabled : Bool = false,
  ~label : String = "",
  ~on_change : Option[(Bool) -> Unit] = None
) -> Toggle {
  Toggle {
    checked,
    focused: false,
    disabled,
    x: 0,
    y: 0,
    width: 0,
    height: 1,
    on_change,
    label,
  }
}

pub fn render(self : Toggle, buffer : Buffer) -> Unit {
  let style = if self.disabled {
    buffer.theme.get_style("disabled")
  } else if self.focused {
    buffer.theme.get_style("focus")
  } else {
    buffer.theme.get_style("normal")
  }
  
  // Draw toggle switch
  let toggle_display = if self.checked { "[●]" } else { "[ ]" }
  buffer.write_string(self.x, self.y, toggle_display, style.fg, style.bg)
  
  // Draw label if provided
  if self.label.length() > 0 {
    buffer.write_string(
      self.x + 4,
      self.y,
      self.label,
      style.fg,
      style.bg
    )
  }
}

pub fn handle_key(self : Toggle, key : String) -> Bool {
  if not(self.focused) || self.disabled {
    return false
  }
  
  match key {
    " " | "Enter" => {
      self.checked = not(self.checked)
      match self.on_change {
        Some(callback) => callback(self.checked)
        None => ()
      }
      true
    }
    _ => false
  }
}

pub fn handle_mouse(self : Toggle, event : MouseEvent) -> Bool {
  if self.disabled {
    return false
  }
  
  // Check if click is within toggle bounds
  let toggle_width = if self.label.length() > 0 { 4 + self.label.length() } else { 3 }
  
  if event.button == MouseButton::Left &&
     event.x >= self.x &&
     event.x < self.x + toggle_width &&
     event.y == self.y {
    self.focused = true
    self.checked = not(self.checked)
    match self.on_change {
      Some(callback) => callback(self.checked)
      None => ()
    }
    return true
  }
  
  false
}

pub fn set_position(self : Toggle, x : Int, y : Int) -> Unit {
  self.x = x
  self.y = y
}

pub fn set_size(self : Toggle, width : Int, height : Int) -> Unit {
  self.width = width
  self.height = height
}

pub fn focus(self : Toggle) -> Unit {
  self.focused = true
}

pub fn blur(self : Toggle) -> Unit {
  self.focused = false
}

pub fn is_checked(self : Toggle) -> Bool {
  self.checked
}

pub fn set_checked(self : Toggle, checked : Bool) -> Unit {
  self.checked = checked
  match self.on_change {
    Some(callback) => callback(checked)
    None => ()
  }
}