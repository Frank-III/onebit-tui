///| Select component for OneBit-TUI
///| Provides a dropdown/selection list similar to TypeScript implementation

/// Select item
pub(all) struct SelectItem {
  label : String
  value : String
  disabled : Bool
}

/// Select component
pub(all) struct Select {
  items : Array[SelectItem]
  mut selected_index : Int
  mut is_open : Bool
  placeholder : String
  max_visible_items : Int
  on_change : ((String) -> Unit)?
}

/// Create a new select component
pub fn Select::new(
  items : Array[SelectItem],
  placeholder~ : String = "Select an option...",
  max_visible_items~ : Int = 5,
  on_change~ : ((String) -> Unit)? = None
) -> Select {
  {
    items,
    selected_index: -1,
    is_open: false,
    placeholder,
    max_visible_items,
    on_change
  }
}

/// Get the currently selected item
pub fn Select::selected_item(self : Select) -> SelectItem? {
  if self.selected_index >= 0 && self.selected_index < self.items.length() {
    Some(self.items[self.selected_index])
  } else {
    None
  }
}

/// Get the display text for the select
pub fn Select::display_text(self : Select) -> String {
  match self.selected_item() {
    Some(item) => item.label
    None => self.placeholder
  }
}

/// Toggle the dropdown
pub fn Select::toggle(self : Select) -> Unit {
  self.is_open = not(self.is_open)
}

/// Open the dropdown
pub fn Select::open(self : Select) -> Unit {
  self.is_open = true
}

/// Close the dropdown
pub fn Select::close(self : Select) -> Unit {
  self.is_open = false
}

/// Select an item by index
pub fn Select::select_index(self : Select, index : Int) -> Unit {
  if index >= 0 && index < self.items.length() && not(self.items[index].disabled) {
    self.selected_index = index
    match self.on_change {
      Some(f) => f(self.items[index].value)
      None => ()
    }
    self.close()
  }
}

/// Move selection up
pub fn Select::move_up(self : Select) -> Unit {
  if not(self.is_open) { return }
  
  let mut new_index = self.selected_index - 1
  
  // Find previous non-disabled item
  while new_index >= 0 && self.items[new_index].disabled {
    new_index = new_index - 1
  }
  
  if new_index >= 0 {
    self.selected_index = new_index
  }
}

/// Move selection down
pub fn Select::move_down(self : Select) -> Unit {
  if not(self.is_open) { return }
  
  let mut new_index = if self.selected_index < 0 { 0 } else { self.selected_index + 1 }
  
  // Find next non-disabled item
  while new_index < self.items.length() && self.items[new_index].disabled {
    new_index = new_index + 1
  }
  
  if new_index < self.items.length() {
    self.selected_index = new_index
  }
}

/// Handle keyboard input
pub fn Select::handle_key(self : Select, key : @ffi.KeyEvent) -> Bool {
  match key {
    @ffi.KeyEvent::Enter | @ffi.KeyEvent::Char(32) => { // Enter or Space
      if self.is_open && self.selected_index >= 0 {
        self.select_index(self.selected_index)
      } else {
        self.toggle()
      }
      true
    }
    @ffi.KeyEvent::Escape => {
      if self.is_open {
        self.close()
        true
      } else {
        false
      }
    }
    @ffi.KeyEvent::ArrowUp => {
      if self.is_open {
        self.move_up()
        true
      } else {
        false
      }
    }
    @ffi.KeyEvent::ArrowDown => {
      if self.is_open {
        self.move_down()
        true
      } else {
        self.open()
        true
      }
    }
    _ => false
  }
}

/// Render the select component
pub fn Select::render(self : Select, buffer : @ffi.Buffer, x : Int, y : Int, width : Int, focused : Bool) -> Unit {
  let display = self.display_text()
  let truncated = if display.length() > width - 3 {
    @core.string_substring(display, 0, width - 6) + "..."
  } else {
    display
  }
  
  // Draw the select box
  let bg_color = if focused { 0.15 } else { 0.1 }
  let border_color = if focused { 0.8 } else { 0.4 }
  
  buffer.fill_rect(
    x.reinterpret_as_uint(), 
    y.reinterpret_as_uint(), 
    width.reinterpret_as_uint(), 
    1_U, 
    bg_color, bg_color, bg_color * 1.2, 1.0
  )
  
  // Draw text
  buffer.draw_text(
    truncated,
    (x + 1).reinterpret_as_uint(),
    y.reinterpret_as_uint(),
    fg_r=0.9, fg_g=0.9, fg_b=0.9
  )
  
  // Draw dropdown arrow
  let arrow = if self.is_open { "▲" } else { "▼" }
  buffer.draw_text(
    arrow,
    (x + width - 2).reinterpret_as_uint(),
    y.reinterpret_as_uint(),
    fg_r=border_color, fg_g=border_color, fg_b=border_color
  )
  
  // Draw dropdown if open
  if self.is_open {
    let dropdown_height = @core.minimum(self.items.length(), self.max_visible_items)
    let dropdown_y = y + 1
    
    // Background for dropdown
    buffer.fill_rect(
      x.reinterpret_as_uint(),
      dropdown_y.reinterpret_as_uint(),
      width.reinterpret_as_uint(),
      dropdown_height.reinterpret_as_uint(),
      0.05, 0.05, 0.08, 1.0
    )
    
    // Draw items
    for i = 0; i < dropdown_height; i = i + 1 {
      let item = self.items[i]
      let item_y = dropdown_y + i
      let is_selected = i == self.selected_index
      
      // Highlight selected item
      if is_selected {
        buffer.fill_rect(
          x.reinterpret_as_uint(),
          item_y.reinterpret_as_uint(),
          width.reinterpret_as_uint(),
          1_U,
          0.2, 0.2, 0.4, 1.0
        )
      }
      
      // Draw item text
      let text_color = if item.disabled { 0.4 } else if is_selected { 1.0 } else { 0.8 }
      let item_text = if item.label.length() > width - 2 {
        @core.string_substring(item.label, 0, width - 5) + "..."
      } else {
        item.label
      }
      
      buffer.draw_text(
        item_text,
        (x + 1).reinterpret_as_uint(),
        item_y.reinterpret_as_uint(),
        fg_r=text_color, fg_g=text_color, fg_b=text_color
      )
    }
    
    // Draw scrollbar if needed
    if self.items.length() > self.max_visible_items {
      // TODO: Implement scrollbar visualization
    }
  }
}

/// Calculate the height needed for rendering
pub fn Select::height(self : Select) -> Int {
  if self.is_open {
    1 + @core.minimum(self.items.length(), self.max_visible_items)
  } else {
    1
  }
}