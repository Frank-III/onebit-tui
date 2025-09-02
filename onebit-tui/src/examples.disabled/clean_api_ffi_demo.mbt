///| Clean API Demo with FFI Rendering

pub fn clean_api_ffi_demo() -> Unit {
  println("=== Clean API with FFI Rendering ===")
  
  // Create the UI using our clean API
  let ui = @core.vstack(spacing=1, [
    // Title
    @core.text("🚀 OneBit TUI - FFI Rendering", style=@core.TextStyle::Bold, color=@core.RGBA::cyan()),
    
    // Main content
    @core.hstack(spacing=2, [
      // Status panel
      @core.box(
        title="System Status",
        border=@core.BorderStyle::Rounded,
        border_color=@core.RGBA::green(),
        children=[
          @core.vstack(spacing=1, [
            @core.text("✓ FFI: Connected", color=@core.RGBA::green()),
            @core.text("◆ FPS: 60", color=@core.RGBA::yellow()),
            @core.text("▪ Buffer: 80x24", color=@core.RGBA::blue()),
            @core.spacer(min_length=1),
            @core.text("Zig Backend Active", style=@core.TextStyle::Dim)
          ])
        ]
      ),
      
      // Info panel
      @core.box(
        title="FFI Features",
        border=@core.BorderStyle::Double,
        border_color=@core.RGBA::magenta(),
        children=[
          @core.vstack([
            @core.text("• Hardware acceleration"),
            @core.text("• Double buffering"),
            @core.text("• Optimized rendering"),
            @core.text("• Native performance")
          ])
        ]
      )
    ]),
    
    // Footer
    @core.padding(1,
      @core.text("Clean API + FFI = Fast & Beautiful", 
        style=@core.TextStyle::Italic,
        align=@core.TextAlign::Center
      )
    )
  ])
  
  // Initialize FFI renderer
  match @ffi.Renderer::new(80.reinterpret_as_uint(), 24.reinterpret_as_uint()) {
    None => {
      println("Failed to create FFI renderer")
      println("Falling back to ANSI rendering...")
      
      // Fallback to ANSI
      let buffer = @core.TerminalBuffer::new(80, 24)
      let ctx = @core.RenderContext {
        buffer: buffer,
        bounds: @core.Rect::new(0, 0, 80, 24)
      }
      ui.render(ctx)
      println(buffer.to_ansi())
    }
    Some(renderer) => {
      // Set background
      renderer.set_background_color(0.05, 0.05, 0.1, 1.0)
      
      // Get FFI buffer
      let ffi_buffer = renderer.get_next_buffer()
      ffi_buffer.clear(0.05, 0.05, 0.1, 1.0)
      
      // Create MoonBit buffer for rendering
      let mb_buffer = @core.TerminalBuffer::new(80, 24)
      let ctx = @core.RenderContext {
        buffer: mb_buffer,
        bounds: @core.Rect::new(0, 0, 80, 24)
      }
      
      // Render to MoonBit buffer
      ui.render(ctx)
      
      // Transfer to FFI buffer
      transfer_buffer_to_ffi(mb_buffer, ffi_buffer)
      
      // Render frame
      renderer.render(force=true)
      
      // Cleanup
      renderer.destroy()
      println("\nFFI rendering complete!")
    }
  }
}

/// Helper to transfer MoonBit buffer to FFI buffer
fn transfer_buffer_to_ffi(mb_buffer : @core.TerminalBuffer, ffi_buffer : @ffi.Buffer) -> Unit {
  for y = 0; y < mb_buffer.height; y = y + 1 {
    for x = 0; x < mb_buffer.width; x = x + 1 {
      let cell = mb_buffer.get_cell(x, y)
      
      // Skip empty cells
      if cell.char == ' ' && cell.bg == @core.RGBA::black() {
        continue
      }
      
      // Convert style to attributes
      let bold = match cell.style {
        @core.TextStyle::Bold => true
        _ => false
      }
      
      let underline = match cell.style {
        @core.TextStyle::Underline => true
        _ => false
      }
      
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
        bold=bold,
        underline=underline
      )
    }
  }
}