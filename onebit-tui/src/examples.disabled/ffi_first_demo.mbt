///| FFI-First Demo - Shows how everything is built on OpenTUI

pub fn ffi_first_demo() -> Unit {
  println("=== OneBit-TUI: FFI-First Architecture ===\n")
  
  // Everything starts with OpenTUI FFI
  match @core.setup_terminal() {
    None => {
      println("Error: OpenTUI is required for OneBit-TUI")
      println("Please ensure OpenTUI is installed")
      return
    }
    Some(renderer) => {
      // Clear with dark background
      renderer.clear()
      
      // Create UI using declarative API
      let ui = @core.vstack(spacing=1, [
        // Header
        @core.padding(1, 
          @core.text("OneBit-TUI + OpenTUI", 
            style=@core.TextStyle::Bold,
            color=@core.RGBA::cyan(),
            align=@core.TextAlign::Center
          )
        ),
        
        // Architecture explanation
        @core.box(
          title="Architecture",
          border=@core.BorderStyle::Double,
          border_color=@core.RGBA::blue(),
          children=[
            @core.vstack(spacing=1, [
              @core.text("Core → FFI → OpenTUI", style=@core.TextStyle::Bold),
              @core.spacer(),
              @core.text("• Core depends on FFI"),
              @core.text("• All rendering via OpenTUI"),
              @core.text("• Hardware accelerated"),
              @core.text("• Native terminal control")
            ])
          ]
        ),
        
        // Benefits
        @core.hstack(spacing=2, [
          @core.box(
            title="Benefits",
            border_color=@core.RGBA::green(),
            children=[
              @core.vstack([
                @core.text("✓ Fast rendering", color=@core.RGBA::green()),
                @core.text("✓ Well maintained", color=@core.RGBA::green()),
                @core.text("✓ Cross platform", color=@core.RGBA::green()),
                @core.text("✓ Simple API", color=@core.RGBA::green())
              ])
            ]
          ),
          
          @core.box(
            title="Features",
            border_color=@core.RGBA::magenta(),
            children=[
              @core.vstack([
                @core.text("• True colors"),
                @core.text("• Unicode support"),
                @core.text("• Mouse events"),
                @core.text("• Animations")
              ])
            ]
          )
        ]),
        
        // Code example
        @core.box(
          title="Example Code",
          border=@core.BorderStyle::Rounded,
          padding=1,
          children=[
            @core.text("let ui = vstack([", style=@core.TextStyle::Dim),
            @core.text("  text(\"Hello OpenTUI!\"),", style=@core.TextStyle::Dim),
            @core.text("  box(title=\"Demo\")", style=@core.TextStyle::Dim),
            @core.text("])", style=@core.TextStyle::Dim)
          ]
        ),
        
        // Status
        @core.spacer(),
        @core.text("FFI Backend: OpenTUI (Zig) | Status: Active", 
          style=@core.TextStyle::Bold,
          color=@core.RGBA::green()
        )
      ])
      
      // Render the UI
      renderer.render_view(ui)
      
      // Add direct FFI call example
      renderer.draw_text(
        "Direct FFI: This text bypasses the view system",
        5, 23,
        color=@core.RGBA::yellow(),
        bold=true
      )
      
      // Present frame
      renderer.present()
      
      // Cleanup
      @core.restore_terminal(renderer)
      
      println("\nDemo complete!")
      println("\nKey Takeaway: Everything in OneBit-TUI is built on OpenTUI's")
      println("solid FFI foundation, giving us reliability and performance.")
    }
  }
}