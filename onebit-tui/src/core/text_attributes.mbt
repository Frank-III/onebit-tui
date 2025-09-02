///| Text attributes support for OneBit-TUI
///| Allows combining multiple text styles similar to TypeScript implementation

/// Text attribute flags matching OpenTUI's implementation
pub enum TextAttribute {
  None
  Bold      // 1 << 0 = 1
  Dim       // 1 << 1 = 2  
  Italic    // 1 << 2 = 4
  Underline // 1 << 3 = 8
  Blink     // 1 << 4 = 16
  Inverse   // 1 << 5 = 32
  Hidden    // 1 << 6 = 64
  Strikethrough // 1 << 7 = 128
} derive(Eq, Show)

/// Convert single attribute to byte flag
pub fn TextAttribute::to_byte(self : TextAttribute) -> Byte {
  match self {
    None => 0
    Bold => 1
    Dim => 2
    Italic => 4
    Underline => 8
    Blink => 16
    Inverse => 32
    Hidden => 64
    Strikethrough => 128
  }
}

/// Combined text attributes that can have multiple styles
pub struct TextAttributes {
  mut value : Byte
}

/// Create empty text attributes
pub fn TextAttributes::new() -> TextAttributes {
  { value: 0 }
}

/// Create text attributes from a single style
pub fn TextAttributes::from_style(style : TextStyle) -> TextAttributes {
  match style {
    TextStyle::None => { value: 0 }
    TextStyle::Bold => { value: 1 }
    TextStyle::Dim => { value: 2 }
    TextStyle::Italic => { value: 4 }
    TextStyle::Underline => { value: 8 }
    TextStyle::Blink => { value: 16 }
    TextStyle::Reverse => { value: 32 }
    TextStyle::Hidden => { value: 64 }
    TextStyle::Strikethrough => { value: 128 }
  }
}

/// Add an attribute
pub fn TextAttributes::add(self : TextAttributes, attr : TextAttribute) -> TextAttributes {
  self.value = self.value.lor(attr.to_byte())
  self
}

/// Remove an attribute
pub fn TextAttributes::remove(self : TextAttributes, attr : TextAttribute) -> TextAttributes {
  self.value = self.value.land(attr.to_byte().lnot())
  self
}

/// Check if has attribute
pub fn TextAttributes::has(self : TextAttributes, attr : TextAttribute) -> Bool {
  self.value.land(attr.to_byte()) != 0
}

/// Toggle an attribute
pub fn TextAttributes::toggle(self : TextAttributes, attr : TextAttribute) -> TextAttributes {
  if self.has(attr) {
    self.remove(attr)
  } else {
    self.add(attr)
  }
}

/// Get the byte value for FFI
pub fn TextAttributes::to_byte(self : TextAttributes) -> Byte {
  self.value
}

/// Convenience builder methods
pub fn TextAttributes::bold(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Bold)
}

pub fn TextAttributes::italic(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Italic)
}

pub fn TextAttributes::underline(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Underline)
}

pub fn TextAttributes::dim(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Dim)
}

pub fn TextAttributes::blink(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Blink)
}

pub fn TextAttributes::inverse(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Inverse)
}

pub fn TextAttributes::hidden(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Hidden)
}

pub fn TextAttributes::strikethrough(self : TextAttributes) -> TextAttributes {
  self.add(TextAttribute::Strikethrough)
}

/// Common attribute combinations
pub fn TextAttributes::emphasis() -> TextAttributes {
  TextAttributes::new().bold().italic()
}

pub fn TextAttributes::error() -> TextAttributes {
  TextAttributes::new().bold().underline()
}

pub fn TextAttributes::warning() -> TextAttributes {
  TextAttributes::new().bold()
}

pub fn TextAttributes::muted() -> TextAttributes {
  TextAttributes::new().dim()
}