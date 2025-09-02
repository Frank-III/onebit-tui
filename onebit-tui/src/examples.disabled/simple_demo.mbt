pub fn simple_main() -> Unit {
  println("OneBit-TUI FFI Demo Starting...")
  
  // Create renderer using FFI
  match @core.Renderer::new(80, 24) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      // Clear screen
      renderer.clear()
      
      // Draw directly using FFI
      renderer.draw_text(
        "╔══════════════════════════════════════╗",
        20, 2,
        color=@core.RGBA::white(),
        bold=true
      )
      renderer.draw_text(
        "║    OneBit-TUI with OpenTUI FFI     ║",
        20, 3,
        color=@core.RGBA::yellow(),
        bold=true
      )
      renderer.draw_text(
        "╚══════════════════════════════════════╝",
        20, 4,
        color=@core.RGBA::white(),
        bold=true
      )
      
      // Draw some colored rectangles
      renderer.fill_rect(10, 7, 25, 8, @core.RGBA::new(0.0, 0.2, 0.0, 1.0))
      renderer.draw_text("[1] New File", 12, 9, color=@core.RGBA::white())
      renderer.draw_text("[2] Open File", 12, 10, color=@core.RGBA::white())
      renderer.draw_text("[3] Save", 12, 11, color=@core.RGBA::white())
      renderer.draw_text("[4] Exit", 12, 12, color=@core.RGBA::white())
      
      // Status area
      renderer.fill_rect(40, 7, 30, 8, @core.RGBA::new(0.0, 0.0, 0.2, 1.0))
      renderer.draw_text("Status", 42, 7, color=@core.RGBA::cyan(), bold=true)
      renderer.draw_text("Ready", 42, 9, color=@core.RGBA::green())
      renderer.draw_text("FFI: Connected", 42, 11, color=@core.RGBA::white())
      renderer.draw_text("Renderer: Active", 42, 12, color=@core.RGBA::white())
      
      // Footer
      renderer.draw_text(
        "Press Enter to exit | FFI Demo",
        20, 20,
        color=@core.RGBA::gray()
      )
      
      // Present the frame
      renderer.present()
      
      // Hide cursor
      @ffi.set_cursor_position(0, 23, visible=false)
      
      // Wait for input
      println("\nPress Enter to exit...")
      ignore(@io.stdin().read_line())
      
      // Cleanup
      renderer.destroy()
      println("Demo completed!")
    }
  }
}

/// Helper function to draw a box
fn draw_box(
  buffer : @core.TerminalBuffer, 
  x : Int, 
  y : Int, 
  width : Int, 
  height : Int, 
  title : String,
  fg : @core.RGBA,
  bg : @core.RGBA
) -> Unit {
  // Top border
  buffer.write_char(x, y, '╔', fg, bg, @core.TextStyle::None)
  for i = 1; i < width - 1; i = i + 1 {
    if i == 2 && title.length() > 0 {
      buffer.write_string(x + i, y, " " + title + " ", fg, bg, @core.TextStyle::Bold)
      break
    }
    buffer.write_char(x + i, y, '═', fg, bg, @core.TextStyle::None)
  }
  
  // Continue top border after title
  let title_end = 3 + title.length() + 1
  for i = title_end; i < width - 1; i = i + 1 {
    buffer.write_char(x + i, y, '═', fg, bg, @core.TextStyle::None)
  }
  buffer.write_char(x + width - 1, y, '╗', fg, bg, @core.TextStyle::None)
  
  // Side borders  
  for j = 1; j < height - 1; j = j + 1 {
    buffer.write_char(x, y + j, '║', fg, bg, @core.TextStyle::None)
    // Fill background
    for i = 1; i < width - 1; i = i + 1 {
      buffer.write_char(x + i, y + j, ' ', fg, bg, @core.TextStyle::None)
    }
    buffer.write_char(x + width - 1, y + j, '║', fg, bg, @core.TextStyle::None)
  }
  
  // Bottom border
  buffer.write_char(x, y + height - 1, '╚', fg, bg, @core.TextStyle::None)
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_char(x + i, y + height - 1, '═', fg, bg, @core.TextStyle::None)
  }
  buffer.write_char(x + width - 1, y + height - 1, '╝', fg, bg, @core.TextStyle::None)
}