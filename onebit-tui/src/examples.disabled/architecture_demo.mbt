///|
/// Demo showing the new component architecture with FFI

pub fn architecture_demo() -> Unit {
  // Setup FFI renderer
  match @core.setup_terminal() {
    None => {
      println("Error: FFI initialization failed")
      println("Make sure OpenTUI is installed")
      return
    }
    Some(renderer) => {
      // Clear screen
      renderer.clear()
      
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
        .with_title("Nested Boxes")
        .with_dimensions(35, 2, 40, 10)
      
      let inner_box = @components.Box::new("inner")
        .with_border_style(@core.BorderStyle::Rounded)
        .with_border_color(@core.RGBA::magenta())
        .with_background_color(@core.RGBA::new(0.2, 0.1, 0.2, 1.0))
        .with_dimensions(5, 3, 30, 5)
      
      let nested_text = @components.Text::new("nested", "OpenTUI Powered!")
        .with_foreground_color(@core.RGBA::white())
        .with_dimensions(2, 2, 26, 1)
      
      inner_box.add_child(nested_text.as_renderable())
      outer_box.add_child(inner_box.as_renderable())
      
      // 3. Group with multiple children
      let group = @components.Group::new("main-group")
      group.add_child(box1.as_renderable())
      group.add_child(outer_box.as_renderable())
      
      // Create MoonBit buffer and render
      let buffer = @core.TerminalBuffer::new(80, 24)
      group.as_renderable().render(buffer)
      
      // Transfer to FFI
      renderer.transfer_from_mb_buffer(buffer)
      
      // Add FFI status
      renderer.draw_text("FFI Rendering Active | OpenTUI Backend", 2, 22, 
        color=@core.RGBA::green(), bold=true)
      
      // Render frame
      renderer.renderer.render(force=true)
      
      // Cleanup
      @core.restore_terminal(renderer)
      
      println("\nFFI Demo complete! This shows:")
      println("- Components rendered via OpenTUI FFI")
      println("- Hardware accelerated rendering")
      println("- Full component flexibility")
    }
  }
}