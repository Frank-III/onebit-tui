///|
/// Core type definitions for OneBit TUI library

///| Text style enumeration
pub(all) enum TextStyle {
  None
  Bold
  Dim
  Italic
  Underline
  Blink
  Reverse
  Hidden
  Strikethrough
} derive(Eq, Show)

///| Border style enumeration
pub(all) enum BorderStyle {
  None
  Single
  Double
  Thick
  Rounded
  Dashed
  Dotted
} derive(Eq, Show)

///|
pub fn BorderStyle::single() -> BorderStyle {
  Single
}

///|
pub fn BorderStyle::none() -> BorderStyle {
  None
}

///| Line style enumeration
pub enum LineStyle {
  None
  Single
  Double
  Thick
  Rounded
  Dashed
  Dotted
  Heavy
  Light
}

///| Corner positions
pub enum Corner {
  TopLeft
  TopRight
  BottomLeft
  BottomRight
}

///| Direction enumeration
pub enum Direction {
  Top
  Right
  Bottom
  Left
}

///| Position structure for 2D coordinates
pub struct Position {
  x : Int
  y : Int
}

///| Rectangle structure for bounds
pub(all) struct Rect {
  x : Int
  y : Int
  width : Int
  height : Int
}

///|
pub fn Rect::new(x : Int, y : Int, width : Int, height : Int) -> Rect {
  { x, y, width, height }
}

///| Size specification with flexible units
pub enum Size {
  Number(Double)
  Auto
  Percent(Double)
}

///| Integer size specification
pub enum IntSize {
  Number(Int)
  Auto
  Percent(Int)
}

///| Flexbox direction
pub enum FlexDirection {
  Row
  Column
  RowReverse
  ColumnReverse
}

///| Flexbox alignment for items
pub enum AlignItems {
  Start
  Center
  End
  Stretch
  Baseline
}

///| Flexbox justification for content
pub enum JustifyContent {
  Start
  Center
  End
  SpaceBetween
  SpaceAround
  SpaceEvenly
}

///| Mouse action types
pub enum MouseAction {
  Down
  Up
  Move
  Drag
  DragEnd
  Drop
  Over
  Out
  Scroll
}

///| Mouse event structure
pub struct MouseEvent {
  action : MouseAction
  x : Int
  y : Int
  button : Int
  shift : Bool
  ctrl : Bool
  alt : Bool
}

///| Keyboard event structure
pub struct KeyEvent {
  key : String
  code : String
  shift : Bool
  ctrl : Bool
  alt : Bool
  meta : Bool
  repeat : Bool
}

///| Selection state for text/areas
pub struct SelectionState {
  start : Position
  end : Position
  active : Bool
}

///| RGBA color structure
pub(all) struct RGBA {
  r : Double
  g : Double
  b : Double
  a : Double
} derive(Eq, Show)

///|
pub fn RGBA::new(r : Double, g : Double, b : Double, a : Double) -> RGBA {
  { r, g, b, a }
}

///|
pub fn RGBA::rgb(r : Double, g : Double, b : Double) -> RGBA {
  { r, g, b, a: 1.0 }
}

///| Default transparent RGBA
pub fn RGBA::default() -> RGBA {
  { r: 0.0, g: 0.0, b: 0.0, a: 0.0 }
}

///| Text alignment options
pub(all) enum TextAlign {
  Left
  Center
  Right
} derive(Eq, Show)

///|
pub fn TextAlign::center() -> TextAlign {
  Center
}

///|
pub fn TextAlign::left() -> TextAlign {
  Left
}

///|
pub fn TextAlign::right() -> TextAlign {
  Right
}

///| Text wrapping options
pub(all) enum TextWrap {
  None
  Word
  Character
} derive(Eq, Show)

///|
pub fn TextWrap::none() -> TextWrap {
  None
}


///| Parse a hex digit code to integer
fn hex_code_to_int(code : Int) -> Int {
  if code >= 48 && code <= 57 { // '0' to '9'
    code - 48
  } else if code >= 65 && code <= 70 { // 'A' to 'F'
    code - 65 + 10
  } else if code >= 97 && code <= 102 { // 'a' to 'f'
    code - 97 + 10
  } else {
    0
  }
}

///| Parse two hex characters to a byte value
fn parse_hex_byte_str(s : String, start : Int) -> Int {
  if start + 1 < s.length() {
    let high = hex_code_to_int(s[start])
    let low = hex_code_to_int(s[start + 1])
    high * 16 + low
  } else if start < s.length() {
    hex_code_to_int(s[start]) * 16
  } else {
    0
  }
}

///| Convert hex color string to RGBA
pub fn hex_to_rgba(hex : String) -> RGBA {
  // Remove leading/trailing whitespace manually
  let mut start_pos = 0
  let mut end_pos = hex.length()

  // Skip leading whitespace
  while start_pos < hex.length() &&
        (
          hex[start_pos] == 32 ||
          hex[start_pos] == 9 ||
          hex[start_pos] == 10 ||
          hex[start_pos] == 13
        ) {
    start_pos += 1
  }

  // Skip trailing whitespace
  while end_pos > start_pos &&
        (
          hex[end_pos - 1] == 32 ||
          hex[end_pos - 1] == 9 ||
          hex[end_pos - 1] == 10 ||
          hex[end_pos - 1] == 13
        ) {
    end_pos -= 1
  }

  // Check for '#' prefix
  let has_hash = start_pos < end_pos && hex[start_pos] == 35 // '#'
  let color_start = if has_hash { start_pos + 1 } else { start_pos }
  let clean_len = end_pos - color_start
  match clean_len {
    3 => {
      let r = hex_code_to_int(hex[color_start]) * 17
      let g = hex_code_to_int(hex[color_start + 1]) * 17
      let b = hex_code_to_int(hex[color_start + 2]) * 17
      {
        r: r.to_double() / 255.0,
        g: g.to_double() / 255.0,
        b: b.to_double() / 255.0,
        a: 1.0,
      }
    }
    6 => {
      let r = parse_hex_byte_str(hex, color_start)
      let g = parse_hex_byte_str(hex, color_start + 2)
      let b = parse_hex_byte_str(hex, color_start + 4)
      {
        r: r.to_double() / 255.0,
        g: g.to_double() / 255.0,
        b: b.to_double() / 255.0,
        a: 1.0,
      }
    }
    8 => {
      let r = parse_hex_byte_str(hex, color_start)
      let g = parse_hex_byte_str(hex, color_start + 2)
      let b = parse_hex_byte_str(hex, color_start + 4)
      let a = parse_hex_byte_str(hex, color_start + 6)
      {
        r: r.to_double() / 255.0,
        g: g.to_double() / 255.0,
        b: b.to_double() / 255.0,
        a: a.to_double() / 255.0,
      }
    }
    _ => { r: 0.0, g: 0.0, b: 0.0, a: 1.0 }
  }
}

///| Convert RGBA colors to ANSI escape codes
pub fn rgba_to_ansi(fg : RGBA, bg : RGBA) -> String {
  let fg_r = (fg.r * 255.0).to_double().to_int()
  let fg_g = (fg.g * 255.0).to_double().to_int()
  let fg_b = (fg.b * 255.0).to_double().to_int()
  let bg_r = (bg.r * 255.0).to_double().to_int()
  let bg_g = (bg.g * 255.0).to_double().to_int()
  let bg_b = (bg.b * 255.0).to_double().to_int()

  // 24-bit color ANSI escape codes
  let fg_code = "\u001b[38;2;\{fg_r};\{fg_g};\{fg_b}m"
  let bg_code = "\u001b[48;2;\{bg_r};\{bg_g};\{bg_b}m"
  fg_code + bg_code
}

// Color constants
pub fn RGBA::white() -> RGBA { RGBA::{ r: 1.0, g: 1.0, b: 1.0, a: 1.0 } }
pub fn RGBA::black() -> RGBA { RGBA::{ r: 0.0, g: 0.0, b: 0.0, a: 1.0 } }
pub fn RGBA::red() -> RGBA { RGBA::{ r: 1.0, g: 0.0, b: 0.0, a: 1.0 } }
pub fn RGBA::green() -> RGBA { RGBA::{ r: 0.0, g: 1.0, b: 0.0, a: 1.0 } }
pub fn RGBA::blue() -> RGBA { RGBA::{ r: 0.0, g: 0.0, b: 1.0, a: 1.0 } }
pub fn RGBA::yellow() -> RGBA { RGBA::{ r: 1.0, g: 1.0, b: 0.0, a: 1.0 } }
pub fn RGBA::cyan() -> RGBA { RGBA::{ r: 0.0, g: 1.0, b: 1.0, a: 1.0 } }
pub fn RGBA::magenta() -> RGBA { RGBA::{ r: 1.0, g: 0.0, b: 1.0, a: 1.0 } }
pub fn RGBA::gray() -> RGBA { RGBA::{ r: 0.5, g: 0.5, b: 0.5, a: 1.0 } }

// Color interpolation
pub fn RGBA::lerp(from : RGBA, to : RGBA, t : Double) -> RGBA {
  RGBA::{
    r: from.r + (to.r - from.r) * t,
    g: from.g + (to.g - from.g) * t,
    b: from.b + (to.b - from.b) * t,
    a: from.a + (to.a - from.a) * t
  }
}

///| Spacing structure for margins and padding
pub struct Spacing {
  top : Int
  right : Int
  bottom : Int
  left : Int
}

pub fn Spacing::zero() -> Spacing {
  Spacing::{ top: 0, right: 0, bottom: 0, left: 0 }
}

pub fn Spacing::all(value : Int) -> Spacing {
  Spacing::{ top: value, right: value, bottom: value, left: value }
}

pub fn Spacing::symmetric(vertical : Int, horizontal : Int) -> Spacing {
  Spacing::{ top: vertical, right: horizontal, bottom: vertical, left: horizontal }
}

///| Extended Border Style with color
pub struct BorderStyleExt {
  style : BorderStyle
  color : RGBA
}

// Removed Renderable trait as traits can't be used as types in MoonBit
// Using CustomRenderable as the concrete type for all renderables

///| Custom renderable wrapper
pub struct CustomRenderable {
  render_fn : (@ffi.Buffer, UInt, UInt, UInt, UInt) -> Unit
}

pub fn CustomRenderable::new(render_fn : (@ffi.Buffer, UInt, UInt, UInt, UInt) -> Unit) -> CustomRenderable {
  CustomRenderable::{ render_fn }
}

pub fn CustomRenderable::render(self : CustomRenderable, buffer : @ffi.Buffer, x : UInt, y : UInt, width : UInt, height : UInt) -> Unit {
  (self.render_fn)(buffer, x, y, width, height)
}
