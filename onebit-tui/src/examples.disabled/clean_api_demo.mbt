///| Demo of the new clean API with FFI rendering

pub fn clean_api_demo() -> Unit {
  // Create a beautiful UI with the new declarative API
  let ui = @core.vstack(spacing=1, [
    // Title
    @core.text("🚀 OneBit TUI - Clean API + FFI", style=@core.TextStyle::Bold, color=@core.RGBA::cyan()),
    
    // Main content area
    @core.hstack(spacing=2, [
      // Left panel
      @core.box(
        title="Status",
        border=@core.BorderStyle::Rounded,
        border_color=@core.RGBA::green(),
        children=[
          @core.vstack(spacing=1, [
            @core.text("✓ System: Online", color=@core.RGBA::green()),
            @core.text("◆ CPU: 42%", color=@core.RGBA::yellow()),
            @core.text("▪ Memory: 1.2GB", color=@core.RGBA::blue()),
            @core.spacer(min_length=1),
            @core.text("FFI Backend: Active", style=@core.TextStyle::Bold, color=@core.RGBA::green())
          ])
        ]
      ),
      
      // Right panel
      @core.box(
        title="Messages",
        border=@core.BorderStyle::Double,
        border_color=@core.RGBA::magenta(),
        children=[
          @core.vstack(alignment=@core.HorizontalAlignment::Leading, [
            @core.text("[12:34] FFI initialized"),
            @core.text("[12:35] OpenTUI connected"),
            @core.text("[12:36] Hardware acceleration ON", style=@core.TextStyle::Bold)
          ])
        ]
      )
    ]),
    
    // Nested boxes demo
    @core.box(
      title="Nested Components",
      padding=2,
      children=[
        @core.hstack([
          @core.text("Text can contain → ", color=@core.RGBA::white()),
          @core.box(
            border=@core.BorderStyle::Single,
            border_color=@core.RGBA::red(),
            children=[@core.text("a box!", color=@core.RGBA::yellow())]
          ),
          @core.text(" ← with FFI!", color=@core.RGBA::white())
        ])
      ]
    ),
    
    // Footer
    @core.padding(1, 
      @core.text("Powered by OpenTUI FFI", 
        style=@core.TextStyle::Italic, 
        align=@core.TextAlign::Center
      )
    )
  ])
  
  // Always use FFI
  match @core.setup_terminal() {
    None => {
      println("Error: Failed to initialize FFI renderer")
      println("Please ensure OpenTUI is properly installed")
    }
    Some(renderer) => {
      // Clear and render
      renderer.clear()
      renderer.render_view(ui)
      
      // Add status line
      renderer.draw_text(
        "FFI Status: Connected | FPS: 60 | Press any key to exit",
        5, 23,
        color=@core.RGBA::green(),
        bold=true
      )
      
      // Present the frame
      renderer.present()
      
      // In a real app, we'd have an event loop here
      // For now, just pause briefly
      
      // Cleanup
      @core.restore_terminal(renderer)
      
      println("\n✨ Clean API Demo with FFI Complete!")
    }
  }
}

/// Even cleaner with a helper function
fn status_line(icon : String, label : String, value : String, color : @core.RGBA) -> @core.View {
  @core.hstack([
    @core.text(icon + " " + label + ": ", style=@core.TextStyle::Dim),
    @core.text(value, color=color)
  ])
}

pub fn clean_api_demo_v2() -> Unit {
  // Even cleaner version using helper functions
  let ui = @core.vstack(spacing=2, [
    @core.text("OneBit TUI + OpenTUI FFI", style=@core.TextStyle::Bold, align=@core.TextAlign::Center),
    
    @core.hstack([
      @core.box(title="System", children=[
        @core.vstack([
          status_line("✓", "Status", "Online", @core.RGBA::green()),
          status_line("◆", "CPU", "42%", @core.RGBA::yellow()),
          status_line("▪", "Memory", "1.2GB", @core.RGBA::blue()),
          status_line("⚡", "FFI", "Active", @core.RGBA::cyan())
        ])
      ]),
      
      @core.box(title="Network", children=[
        @core.vstack([
          status_line("↓", "Download", "125 MB/s", @core.RGBA::cyan()),
          status_line("↑", "Upload", "25 MB/s", @core.RGBA::magenta()),
          status_line("◉", "Ping", "12ms", @core.RGBA::green()),
          status_line("🔌", "OpenTUI", "Connected", @core.RGBA::green())
        ])
      ])
    ])
  ])
  
  // Render with FFI
  match @core.setup_terminal() {
    None => println("FFI initialization failed")
    Some(renderer) => {
      renderer.clear()
      renderer.render_view(ui)
      renderer.present()
      @core.restore_terminal(renderer)
    }
  }
}