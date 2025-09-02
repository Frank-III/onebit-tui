///|
/// Demo showing the new component architecture with FFI rendering

pub fn architecture_demo_ffi() -> Unit {
  println("=== OneBit-TUI Architecture Demo with FFI ===")
  
  // Create FFI renderer
  match @ffi.Renderer::new(80.reinterpret_as_uint(), 24.reinterpret_as_uint()) {
    None => {
      println("Failed to create FFI renderer")
      return
    }
    Some(renderer) => {
      println("Created FFI renderer: 80x24")
      
      // Set dark background
      renderer.set_background_color(0.05, 0.05, 0.1, 1.0)
      
      // Get the buffer to draw on
      let ffi_buffer = renderer.get_next_buffer()
      println("Got FFI buffer: \{ffi_buffer.width}x\{ffi_buffer.height}")
      
      // Clear buffer
      ffi_buffer.clear(0.0, 0.0, 0.1, 1.0)
      
      // Create our MoonBit buffer for rendering
      let buffer = @core.TerminalBuffer::new(80, 24)
      
      // Create components demonstrating flexible composition
      
      // 1. Text inside Box
      let box1 = @components.Box::new("box1")
        .with_border_style(@core.BorderStyle::Single)
        .with_border_color(@core.RGBA::cyan())
        .with_title("Text in Box")
        .with_background_color(@core.RGBA::new(0.1, 0.1, 0.2, 1.0))
        .with_dimensions(2, 2, 30, 5)
      
      let text1 = @components.Text::new("text1", "Hello from FFI!")
        .with_foreground_color(@core.RGBA::yellow())
        .with_align(@core.TextAlign::Center)
        .with_dimensions(2, 2, 26, 1)
      
      box1.add_child(text1.as_renderable())
      
      // 2. Box inside Box 
      let outer_box = @components.Box::new("outer")
        .with_border_style(@core.BorderStyle::Double)
        .with_border_color(@core.RGBA::green())
        .with_title("Nested with FFI")
        .with_dimensions(35, 2, 40, 10)
      
      let inner_box = @components.Box::new("inner")
        .with_border_style(@core.BorderStyle::Rounded)
        .with_border_color(@core.RGBA::magenta())
        .with_background_color(@core.RGBA::new(0.2, 0.1, 0.2, 1.0))
        .with_dimensions(5, 3, 30, 5)
      
      let nested_text = @components.Text::new("nested", "FFI Rendering!")
        .with_foreground_color(@core.RGBA::white())
        .with_dimensions(2, 2, 26, 1)
      
      inner_box.add_child(nested_text.as_renderable())
      outer_box.add_child(inner_box.as_renderable())
      
      // 3. Group with multiple children
      let group = @components.Group::new("main-group")
      group.add_child(box1.as_renderable())
      group.add_child(outer_box.as_renderable())
      
      // Render to our buffer
      group.as_renderable().render(buffer)
      
      // Transfer from MoonBit buffer to FFI buffer
      for y = 0; y < 24; y = y + 1 {
        for x = 0; x < 80; x = x + 1 {
          let cell = buffer.get_cell(x, y)
          if cell.char != ' ' || cell.bg != @core.RGBA::black() {
            // Draw to FFI buffer
            ffi_buffer.draw_text(
              cell.char.to_string(),
              x.reinterpret_as_uint(),
              y.reinterpret_as_uint(),
              fg_r=cell.fg.r.to_float(),
              fg_g=cell.fg.g.to_float(),
              fg_b=cell.fg.b.to_float(),
              bg_r=cell.bg.r.to_float(),
              bg_g=cell.bg.g.to_float(),
              bg_b=cell.bg.b.to_float(),
              bold=cell.style == @core.TextStyle::Bold
            )
          }
        }
      }
      
      // Add status text
      ffi_buffer.draw_text("FFI Status: Connected ✓", 5, 20,
        fg_r=0.2, fg_g=1.0, fg_b=0.2, bold=true)
      
      // Render the frame
      renderer.render(force=true)
      println("Rendered frame via FFI")
      
      // In a real app, we'd have an event loop here
      // For demo, just wait before cleanup
      
      // Clean up
      renderer.destroy()
      println("Cleaned up FFI renderer")
    }
  }
  
  println("\n=== FFI Demo complete ===")
}