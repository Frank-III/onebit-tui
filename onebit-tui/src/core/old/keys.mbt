///| Proper key and event enums for better DX
///| No more magic numbers!

/// Keyboard key representation
pub enum Key {
  // Printable characters
  Char(Char)
  
  // Control keys
  Enter
  Tab
  Escape
  Backspace
  Delete
  Space
  
  // Navigation
  Up
  Down
  Left
  Right
  Home
  End
  PageUp
  PageDown
  
  // Function keys
  F(Int)  // F1-F12
  
  // Modifiers + key combinations
  Ctrl(Char)  // Ctrl+C, Ctrl+V, etc.
  Alt(Char)   // Alt+F, etc.
  
  // Unknown
  Unknown(Int)  // Fallback for unrecognized codes
} derive(Eq, Hash)

/// Mouse button types
pub enum MouseButton {
  Left
  Middle
  Right
  ScrollUp
  ScrollDown
}

/// Mouse action types
pub enum MouseAction {
  Press
  Release
  Drag
}

/// Complete event type
pub enum Event {
  Key(Key)
  Mouse(Int, Int, MouseButton?, MouseAction)  // x, y, button, action
  Resize(Int, Int)  // width, height
  Focus
  Blur
  Paste(String)
}

/// Convert raw key byte to Key enum
pub fn Key::from_byte(b : Int) -> Key {
  match b {
    // Control characters
    13 => Key::Enter
    9 => Key::Tab
    27 => Key::Escape
    127 => Key::Backspace
    8 => Key::Backspace  // Alternative backspace
    32 => Key::Space
    
    // Printable ASCII
    b if b >= 32 && b <= 126 => Key::Char(b.unsafe_to_char())
    
    // Common Ctrl combinations
    1 => Key::Ctrl('a')   // Ctrl+A
    3 => Key::Ctrl('c')   // Ctrl+C
    4 => Key::Ctrl('d')   // Ctrl+D
    5 => Key::Ctrl('e')   // Ctrl+E
    11 => Key::Ctrl('k')  // Ctrl+K
    12 => Key::Ctrl('l')  // Ctrl+L
    22 => Key::Ctrl('v')  // Ctrl+V
    23 => Key::Ctrl('w')  // Ctrl+W
    24 => Key::Ctrl('x')  // Ctrl+X
    26 => Key::Ctrl('z')  // Ctrl+Z
    
    // Fallback
    _ => Key::Unknown(b)
  }
}

/// Key to string representation for debugging
pub fn Key::to_string(self : Key) -> String {
  match self {
    Key::Char(c) => c.to_string()
    Key::Enter => "<Enter>"
    Key::Tab => "<Tab>"
    Key::Escape => "<Esc>"
    Key::Backspace => "<Backspace>"
    Key::Delete => "<Delete>"
    Key::Space => "<Space>"
    Key::Up => "<Up>"
    Key::Down => "<Down>"
    Key::Left => "<Left>"
    Key::Right => "<Right>"
    Key::Home => "<Home>"
    Key::End => "<End>"
    Key::PageUp => "<PageUp>"
    Key::PageDown => "<PageDown>"
    Key::F(n) => "<F" + n.to_string() + ">"
    Key::Ctrl(c) => "<Ctrl+" + c.to_string() + ">"
    Key::Alt(c) => "<Alt+" + c.to_string() + ">"
    Key::Unknown(b) => "<Unknown:" + b.to_string() + ">"
  }
}

/// Helper to check if key is a printable character
pub fn Key::is_printable(self : Key) -> Bool {
  match self {
    Key::Char(_) => true
    _ => false
  }
}

/// Helper to check if key is a navigation key
pub fn Key::is_nav(self : Key) -> Bool {
  match self {
    Key::Up | Key::Down | Key::Left | Key::Right |
    Key::Home | Key::End | Key::PageUp | Key::PageDown => true
    _ => false
  }
}

/// Helper to check if key is a modifier combo
pub fn Key::is_modified(self : Key) -> Bool {
  match self {
    Key::Ctrl(_) | Key::Alt(_) => true
    _ => false
  }
}