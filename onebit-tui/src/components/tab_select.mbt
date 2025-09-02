pub(all) struct TabSelectItem {
  label : String
  value : String
  disabled : Bool
}

pub(all) struct TabSelect {
  mut items : Array[TabSelectItem]
  mut selected_index : Int
  mut focused : Bool
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  mut on_change : Option[(String) -> Unit]
}

pub fn TabSelect::new(
  items : Array[TabSelectItem],
  ~selected_index : Int = 0,
  ~on_change : Option[(String) -> Unit] = None
) -> TabSelect {
  TabSelect {
    items,
    selected_index,
    focused: false,
    x: 0,
    y: 0,
    width: 0,
    height: 1,
    on_change,
  }
}

pub fn render(self : TabSelect, buffer : Buffer) -> Unit {
  let mut x_offset = 0
  
  for i, item in self.items {
    let is_selected = i == self.selected_index
    let is_disabled = item.disabled
    
    // Tab styling
    let style = if is_disabled {
      buffer.theme.get_style("disabled")
    } else if is_selected && self.focused {
      buffer.theme.get_style("focus")
    } else if is_selected {
      buffer.theme.get_style("selected")
    } else {
      buffer.theme.get_style("normal")
    }
    
    // Draw tab background
    let tab_width = item.label.length() + 4 // 2 spaces padding on each side
    buffer.fill_rect(
      self.x + x_offset,
      self.y,
      tab_width,
      self.height,
      ' ',
      style.fg,
      style.bg
    )
    
    // Draw tab text
    buffer.write_string(
      self.x + x_offset + 2,
      self.y,
      item.label,
      style.fg,
      style.bg
    )
    
    // Draw separator between tabs (except for last tab)
    if i < self.items.length() - 1 {
      buffer.write_string(
        self.x + x_offset + tab_width,
        self.y,
        "│",
        buffer.theme.get_style("border").fg,
        buffer.theme.get_style("border").bg
      )
    }
    
    x_offset += tab_width + 1 // +1 for separator
  }
}

pub fn handle_key(self : TabSelect, key : String) -> Bool {
  if not(self.focused) {
    return false
  }
  
  match key {
    "ArrowLeft" | "h" => {
      // Move to previous non-disabled item
      let mut new_index = self.selected_index - 1
      while new_index >= 0 && self.items[new_index].disabled {
        new_index -= 1
      }
      if new_index >= 0 {
        self.selected_index = new_index
        match self.on_change {
          Some(callback) => callback(self.items[new_index].value)
          None => ()
        }
      }
      true
    }
    "ArrowRight" | "l" => {
      // Move to next non-disabled item
      let mut new_index = self.selected_index + 1
      while new_index < self.items.length() && self.items[new_index].disabled {
        new_index += 1
      }
      if new_index < self.items.length() {
        self.selected_index = new_index
        match self.on_change {
          Some(callback) => callback(self.items[new_index].value)
          None => ()
        }
      }
      true
    }
    "Home" => {
      // Move to first non-disabled item
      let mut new_index = 0
      while new_index < self.items.length() && self.items[new_index].disabled {
        new_index += 1
      }
      if new_index < self.items.length() {
        self.selected_index = new_index
        match self.on_change {
          Some(callback) => callback(self.items[new_index].value)
          None => ()
        }
      }
      true
    }
    "End" => {
      // Move to last non-disabled item
      let mut new_index = self.items.length() - 1
      while new_index >= 0 && self.items[new_index].disabled {
        new_index -= 1
      }
      if new_index >= 0 {
        self.selected_index = new_index
        match self.on_change {
          Some(callback) => callback(self.items[new_index].value)
          None => ()
        }
      }
      true
    }
    _ => false
  }
}

pub fn handle_mouse(self : TabSelect, event : MouseEvent) -> Bool {
  if event.y != self.y || event.y >= self.y + self.height {
    return false
  }
  
  let mut x_offset = 0
  for i, item in self.items {
    let tab_width = item.label.length() + 4
    
    if event.x >= self.x + x_offset && event.x < self.x + x_offset + tab_width {
      if not(item.disabled) && event.button == MouseButton::Left {
        self.selected_index = i
        self.focused = true
        match self.on_change {
          Some(callback) => callback(item.value)
          None => ()
        }
        return true
      }
    }
    
    x_offset += tab_width + 1
  }
  
  false
}

pub fn set_position(self : TabSelect, x : Int, y : Int) -> Unit {
  self.x = x
  self.y = y
}

pub fn set_size(self : TabSelect, width : Int, height : Int) -> Unit {
  self.width = width
  self.height = height
}

pub fn focus(self : TabSelect) -> Unit {
  self.focused = true
}

pub fn blur(self : TabSelect) -> Unit {
  self.focused = false
}

pub fn get_selected_value(self : TabSelect) -> String {
  if self.selected_index >= 0 && self.selected_index < self.items.length() {
    self.items[self.selected_index].value
  } else {
    ""
  }
}