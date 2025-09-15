///|
/// Tests for Terminal Buffer System

test "cell creation and defaults" {
  let cell = Cell::default()
  assert_eq(cell.char, ' ')
  assert_eq(cell.fg_color, RGBA::white())
  assert_eq(cell.bg_color, RGBA::black())
  assert_eq(cell.style, TextStyle::None)
}

test "cell creation with character" {
  let cell = Cell::new('A')
  assert_eq(cell.char, 'A')
  assert_eq(cell.fg_color, RGBA::white())
  assert_eq(cell.bg_color, RGBA::black())
}

test "cell color modification" {
  let cell = Cell::new('X')
    .set_fg_color(RGBA::red())
    .set_bg_color(RGBA::blue())
  
  assert_eq(cell.fg_color, RGBA::red())
  assert_eq(cell.bg_color, RGBA::blue())
}

test "cell style modification" {
  let cell = Cell::new('*')
    .set_style(TextStyle::Bold)
  
  assert_eq(cell.style, TextStyle::Bold)
}

test "buffer creation with dimensions" {
  let buffer = TerminalBuffer::new(10, 5)
  assert_eq(buffer.width(), 10)
  assert_eq(buffer.height(), 5)
}

test "buffer initial cursor position" {
  let buffer = TerminalBuffer::new(80, 24)
  let (x, y) = buffer.get_cursor_pos()
  assert_eq(x, 0)
  assert_eq(y, 0)
}

test "buffer cursor movement" {
  let buffer = TerminalBuffer::new(80, 24)
  buffer.set_cursor_pos(10, 5)
  let (x, y) = buffer.get_cursor_pos()
  assert_eq(x, 10)
  assert_eq(y, 5)
}

test "buffer cursor visibility" {
  let buffer = TerminalBuffer::new(80, 24)
  assert_true(buffer.get_cursor_visible())
  
  buffer.set_cursor_visible(false)
  assert_false(buffer.get_cursor_visible())
  
  buffer.set_cursor_visible(true)
  assert_true(buffer.get_cursor_visible())
}

test "buffer write char in bounds" {
  let buffer = TerminalBuffer::new(10, 10)
  buffer.write_char(5, 5, 'A', RGBA::white(), RGBA::black(), TextStyle::None)
  
  match buffer.get_cell(5, 5) {
    Some(cell) => {
      assert_eq(cell.char, 'A')
      assert_eq(cell.fg_color, RGBA::white())
      assert_eq(cell.bg_color, RGBA::black())
    }
    None => assert_true(false) // Should not happen
  }
}

test "buffer write char out of bounds" {
  let buffer = TerminalBuffer::new(10, 10)
  // This should not crash, just be ignored
  buffer.write_char(20, 20, 'X', RGBA::white(), RGBA::black(), TextStyle::None)
  
  // Cell should not exist
  match buffer.get_cell(20, 20) {
    Some(_) => assert_true(false) // Should not happen
    None => assert_true(true)
  }
}

test "buffer write string" {
  let buffer = TerminalBuffer::new(20, 10)
  buffer.write_string(2, 3, "Hello", RGBA::green(), RGBA::black(), TextStyle::None)
  
  // Check each character
  let expected = ['H', 'e', 'l', 'l', 'o']
  for i = 0; i < 5; i = i + 1 {
    match buffer.get_cell(2 + i, 3) {
      Some(cell) => {
        assert_eq(cell.char, expected[i])
        assert_eq(cell.fg_color, RGBA::green())
      }
      None => assert_true(false)
    }
  }
}

test "buffer fill rect" {
  let buffer = TerminalBuffer::new(10, 10)
  buffer.fill_rect(2, 2, 4, 3, '#', RGBA::yellow(), RGBA::gray(), TextStyle::Bold)
  
  // Check that the rectangle is filled correctly
  for y = 2; y < 5; y = y + 1 {
    for x = 2; x < 6; x = x + 1 {
      match buffer.get_cell(x, y) {
        Some(cell) => {
          assert_eq(cell.char, '#')
          assert_eq(cell.fg_color, RGBA::yellow())
          assert_eq(cell.bg_color, RGBA::gray())
          assert_eq(cell.style, TextStyle::Bold)
        }
        None => assert_true(false)
      }
    }
  }
  
  // Check outside the rectangle is unchanged
  match buffer.get_cell(1, 1) {
    Some(cell) => assert_eq(cell.char, ' ')
    None => assert_true(false)
  }
}

test "buffer clear" {
  let buffer = TerminalBuffer::new(5, 5)
  
  // Write some content
  buffer.write_string(0, 0, "XXXXX", RGBA::red(), RGBA::blue(), TextStyle::None)
  buffer.write_string(0, 1, "YYYYY", RGBA::green(), RGBA::yellow(), TextStyle::Bold)
  
  // Clear buffer
  buffer.clear()
  
  // All cells should be default
  for y = 0; y < 5; y = y + 1 {
    for x = 0; x < 5; x = x + 1 {
      match buffer.get_cell(x, y) {
        Some(cell) => {
          assert_eq(cell.char, ' ')
          assert_eq(cell.fg_color, RGBA::white())
          assert_eq(cell.bg_color, RGBA::black())
          assert_eq(cell.style, TextStyle::None)
        }
        None => assert_true(false)
      }
    }
  }
}

test "buffer to string representation" {
  let buffer = TerminalBuffer::new(5, 3)
  buffer.write_string(0, 0, "ABC", RGBA::white(), RGBA::black(), TextStyle::None)
  buffer.write_string(0, 1, "DEF", RGBA::white(), RGBA::black(), TextStyle::None)
  buffer.write_string(0, 2, "GHI", RGBA::white(), RGBA::black(), TextStyle::None)
  
  let str = buffer.to_string()
  assert_true(str.contains("ABC"))
  assert_true(str.contains("DEF"))
  assert_true(str.contains("GHI"))
}

test "buffer boundary conditions" {
  let buffer = TerminalBuffer::new(10, 10)
  
  // Test exact boundaries
  buffer.write_char(0, 0, 'A', RGBA::white(), RGBA::black(), TextStyle::None)
  buffer.write_char(9, 9, 'Z', RGBA::white(), RGBA::black(), TextStyle::None)
  
  assert_true(buffer.get_cell(0, 0).is_some())
  assert_true(buffer.get_cell(9, 9).is_some())
  assert_false(buffer.get_cell(10, 10).is_some())
  assert_false(buffer.get_cell(-1, -1).is_some())
}

test "buffer string truncation" {
  let buffer = TerminalBuffer::new(10, 10)
  buffer.write_string(8, 0, "Hello World", RGBA::white(), RGBA::black(), TextStyle::None)
  
  // Only "He" should be written (positions 8 and 9)
  match buffer.get_cell(8, 0) {
    Some(cell) => assert_eq(cell.char, 'H')
    None => assert_true(false)
  }
  
  match buffer.get_cell(9, 0) {
    Some(cell) => assert_eq(cell.char, 'e')
    None => assert_true(false)
  }
  
  // Position 10 is out of bounds
  assert_false(buffer.get_cell(10, 0).is_some())
}

test "buffer fill rect clipping" {
  let buffer = TerminalBuffer::new(10, 10)
  // Try to fill a rectangle that goes out of bounds
  buffer.fill_rect(8, 8, 5, 5, '*', RGBA::white(), RGBA::black(), TextStyle::None)
  
  // Only the part within bounds should be filled
  assert_true(buffer.get_cell(8, 8).is_some())
  assert_true(buffer.get_cell(9, 9).is_some())
  assert_false(buffer.get_cell(10, 10).is_some())
}

test "rgba color equality" {
  let color1 = RGBA::rgb(0.5, 0.5, 0.5)
  let color2 = RGBA::rgb(0.5, 0.5, 0.5)
  let color3 = RGBA::rgb(0.6, 0.5, 0.5)
  
  assert_eq(color1, color2)
  assert_true(color1 != color3)
}

test "text style equality" {
  assert_eq(TextStyle::None, TextStyle::None)
  assert_eq(TextStyle::Bold, TextStyle::Bold)
  assert_true(TextStyle::Bold != TextStyle::Italic)
}

// Helper to check string contains substring
fn String::contains(self : String, substr : String) -> Bool {
  for i = 0; i <= self.length() - substr.length(); i = i + 1 {
    let mut matches = true
    for j = 0; j < substr.length(); j = j + 1 {
      if self[i + j] != substr[j] {
        matches = false
        break
      }
    }
    if matches {
      return true
    }
  }
  false
}

