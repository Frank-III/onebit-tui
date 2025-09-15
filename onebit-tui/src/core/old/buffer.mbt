/// A single cell in the terminal buffer
pub struct Cell {
  char : Char
  fg_color : RGBA
  bg_color : RGBA
  style : TextStyle
}

/// Default cell with space character and default colors
pub fn Cell::default() -> Cell {
  {
    char: ' ',
    fg_color: { r: 1.0, g: 1.0, b: 1.0, a: 1.0 },
    bg_color: { r: 0.0, g: 0.0, b: 0.0, a: 1.0 },
    style: TextStyle::None
  }
}

/// Create a new cell with the given character
pub fn Cell::new(char : Char) -> Cell {
  { ..Cell::default(), char: char }
}

/// Set the foreground color
pub fn Cell::set_fg_color(self : Cell, color : RGBA) -> Cell {
  { ..self, fg_color: color }
}

/// Set the background color
pub fn Cell::set_bg_color(self : Cell, color : RGBA) -> Cell {
  { ..self, bg_color: color }
}

/// Set the text style
pub fn Cell::set_style(self : Cell, style : TextStyle) -> Cell {
  { ..self, style: style }
}

/// Clear the cell (reset to default)
pub fn Cell::clear(self : Cell) -> Cell {
  Cell::default()
}

/// Terminal buffer that stores the state of the terminal
pub struct TerminalBuffer {
  width : Int
  height : Int
  buffer : Array[Array[Cell]]
  mut cursor_x : Int
  mut cursor_y : Int
  mut cursor_visible : Bool
}

/// Create a new terminal buffer with the given dimensions
pub fn TerminalBuffer::new(width : Int, height : Int) -> TerminalBuffer {
    let buffer = Array::make(height, Array::make(width, Cell::default()))
    for i = 0; i < height; i = i + 1 {
      buffer[i] = Array::make(width, Cell::default())
    }
    {
      width: width,
      height: height,
      buffer: buffer,
      cursor_x: 0,
      cursor_y: 0,
      cursor_visible: true
    }
  }

/// Get the width of the buffer
pub fn TerminalBuffer::width(self : TerminalBuffer) -> Int {
    self.width
  }

/// Get the height of the buffer
pub fn TerminalBuffer::height(self : TerminalBuffer) -> Int {
    self.height
  }

/// Get a cell at the specified position
pub fn TerminalBuffer::get_cell(self : TerminalBuffer, x : Int, y : Int) -> Cell? {
    if x < 0 || x >= self.width || y < 0 || y >= self.height {
      None
    } else {
      Some(self.buffer[y][x])
    }
  }

/// Set a cell at the specified position
pub fn TerminalBuffer::set_cell(self : TerminalBuffer, x : Int, y : Int, cell : Cell) -> Unit {
    if x >= 0 && x < self.width && y >= 0 && y < self.height {
      self.buffer[y][x] = cell
    }
  }

/// Write a character to the buffer
pub fn TerminalBuffer::write_char(self : TerminalBuffer, x : Int, y : Int, char : Char, fg_color : RGBA, bg_color : RGBA, style : TextStyle) -> Unit {
    if x >= 0 && x < self.width && y >= 0 && y < self.height {
      let cell = Cell::new(char)
        .set_fg_color(fg_color)
        .set_bg_color(bg_color)
        .set_style(style)
      self.buffer[y][x] = cell
    }
  }

/// Write a string to the buffer
pub fn TerminalBuffer::write_string(self : TerminalBuffer, x : Int, y : Int, text : String, fg_color : RGBA, bg_color : RGBA, style : TextStyle) -> Unit {
    for i = 0; i < text.length(); i = i + 1 {
      // Get the character at position i
      // Note: text[i] returns Int, we need to convert to Char
      match text[i].to_char() {
        Some(char) => self.write_char(x + i, y, char, fg_color, bg_color, style)
        None => ()
      }
    }
  }

/// Fill a rectangle with a character
pub fn TerminalBuffer::fill_rect(self : TerminalBuffer, x : Int, y : Int, width : Int, height : Int, char : Char, fg_color : RGBA, bg_color : RGBA, style : TextStyle) -> Unit {
    for dy = 0; dy < height; dy = dy + 1 {
      for dx = 0; dx < width; dx = dx + 1 {
        let px = x + dx
        let py = y + dy
        if px >= 0 && px < self.width && py >= 0 && py < self.height {
          self.write_char(px, py, char, fg_color, bg_color, style)
        }
      }
    }
  }

/// Clear the entire buffer
pub fn TerminalBuffer::clear(self : TerminalBuffer) -> Unit {
    for y = 0; y < self.height; y = y + 1 {
      for x = 0; x < self.width; x = x + 1 {
        self.buffer[y][x] = Cell::default()
      }
    }
  }

/// Set the cursor position
pub fn TerminalBuffer::set_cursor_pos(self : TerminalBuffer, x : Int, y : Int) -> Unit {
    self.cursor_x = x
    self.cursor_y = y
  }

/// Get the cursor position
pub fn TerminalBuffer::get_cursor_pos(self : TerminalBuffer) -> (Int, Int) {
    (self.cursor_x, self.cursor_y)
  }

/// Set cursor visibility
pub fn TerminalBuffer::set_cursor_visible(self : TerminalBuffer, visible : Bool) -> Unit {
    self.cursor_visible = visible
  }

/// Get cursor visibility
pub fn TerminalBuffer::get_cursor_visible(self : TerminalBuffer) -> Bool {
    self.cursor_visible
  }

/// Convert the buffer to a string representation for debugging
pub fn TerminalBuffer::to_string(self : TerminalBuffer) -> String {
    let mut result = ""
    for y = 0; y < self.height; y = y + 1 {
      for x = 0; x < self.width; x = x + 1 {
        result += self.buffer[y][x].char.to_string()
      }
      if y < self.height - 1 {
        result += "\n"
      }
    }
    result
  }

/// Convert the buffer to ANSI escape codes
pub fn TerminalBuffer::to_ansi(self : TerminalBuffer) -> String {
    let mut result = ""
    let mut current_fg = RGBA::{ r: 1.0, g: 1.0, b: 1.0, a: 1.0 }
    let mut current_bg = RGBA::{ r: 0.0, g: 0.0, b: 0.0, a: 1.0 }
    let mut current_style = TextStyle::None

    for y = 0; y < self.height; y = y + 1 {
      for x = 0; x < self.width; x = x + 1 {
        let cell = self.buffer[y][x]
        
        // Check if colors or style changed
        if cell.fg_color != current_fg || cell.bg_color != current_bg || cell.style != current_style {
          result += rgba_to_ansi(cell.fg_color, cell.bg_color)
          current_fg = cell.fg_color
          current_bg = cell.bg_color
          current_style = cell.style
        }
        
        result += cell.char.to_string()
      }
      result += "\n"
    }
    
    // Reset colors at the end
    result += "\u001b[0m"
    result
}