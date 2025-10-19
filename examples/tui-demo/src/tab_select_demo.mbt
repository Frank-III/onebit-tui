///|
/// Demo showcasing the TabSelect widget
fn main_tab_select_demo() -> Unit {
  let app = @core.App::init()
  match app {
    None => println("Failed to initialize app")
    Some(app) => {
      // Tab data
      let tabs = ["Dashboard", "Settings", "Profile", "Notifications", "Help"]
      let selected_tab = Ref::new(0)
      
      // Content for each tab
      fn get_tab_content(index : Int) -> Array[@view.View] {
        match index {
          0 => [
            @view.View::text("📊 Dashboard Content", color=@core.Color::Cyan),
            @view.View::text("", color=@core.Color::White),  // Empty line
            @view.View::text("• Total Users: 1,234", color=@core.Color::White),
            @view.View::text("• Active Sessions: 42", color=@core.Color::Green),
            @view.View::text("• CPU Usage: 23%", color=@core.Color::Yellow),
            @view.View::text("• Memory: 4.2 GB / 8 GB", color=@core.Color::White),
          ]
          1 => [
            @view.View::text("⚙️ Settings", color=@core.Color::Cyan),
            @view.View::text("", color=@core.Color::White),
            @view.View::text("[ ] Dark Mode", color=@core.Color::White),
            @view.View::text("[✓] Auto-save", color=@core.Color::Green),
            @view.View::text("[✓] Show notifications", color=@core.Color::Green),
            @view.View::text("[ ] Verbose logging", color=@core.Color::White),
          ]
          2 => [
            @view.View::text("👤 User Profile", color=@core.Color::Cyan),
            @view.View::text("", color=@core.Color::White),
            @view.View::text("Name: John Doe", color=@core.Color::White),
            @view.View::text("Email: john@example.com", color=@core.Color::White),
            @view.View::text("Role: Administrator", color=@core.Color::Yellow),
            @view.View::text("Last Login: 2 hours ago", color=@core.Color::Gray),
          ]
          3 => [
            @view.View::text("🔔 Notifications", color=@core.Color::Cyan),
            @view.View::text("", color=@core.Color::White),
            @view.View::text("• System update available", color=@core.Color::Yellow),
            @view.View::text("• Backup completed successfully", color=@core.Color::Green),
            @view.View::text("• New user registered", color=@core.Color::White),
            @view.View::text("• Disk space warning (85% used)", color=@core.Color::Red),
          ]
          _ => [
            @view.View::text("❓ Help & Documentation", color=@core.Color::Cyan),
            @view.View::text("", color=@core.Color::White),
            @view.View::text("Keyboard Shortcuts:", color=@core.Color::Yellow),
            @view.View::text("• Arrow Keys: Navigate tabs", color=@core.Color::White),
            @view.View::text("• Home/End: First/Last tab", color=@core.Color::White),
            @view.View::text("• 1-5: Quick select tab", color=@core.Color::White),
            @view.View::text("• Tab: Focus next element", color=@core.Color::White),
            @view.View::text("• q: Quit application", color=@core.Color::White),
          ]
        }
      }
      
      // Create tab select widget
      let tab_select = @widget.TabSelect::new(
        tabs,
        fn(t) { t },
        selected=selected_tab
      )
        .on_change(fn(_index, _tab) { })
      
      // Simple status line for debugging focus and key events
      let status = Ref::new("Tab demo ready".to_string())
      let debug_overlay_on = Ref::new(false)

      fn build_ui() -> @view.View {
        // Get content for selected tab
        let content_views = get_tab_content(selected_tab.val)
        
        @view.View::container_views([
          // Title
          @view.View::text("TabSelect Widget Demo", color=@core.Color::Yellow)
            .padding(1.0),
          
          // Tab selector
          tab_select.render(),
          
          // Content area with border
          @view.View::container_views(content_views)
            .direction(@view.Direction::Column)
            .spacing(0.5)
            .padding(2.0)
            .border(@view.BorderStyle::Single, color=@core.Color::White)
            .overflow_y(@view.Overflow::Hidden)
            .height(12.0)  // Fixed height for content area
            .width(50.0)   // Fixed width
            .focusable()
            .focused_border_color(@core.Color::Cyan)
            .on_event(fn(ev) {
              match ev {
                @events.Event::Key(key) => {
                  let pk = @events.parse_key_event_simple(key)
                  status.val = "Content key: ".to_string() + pk.name
                  true
                }
                @events.Event::KeyMod(key, mods) => {
                  let pk = @events.parse_key_event(key, mods)
                  let mods_label = (if pk.ctrl { "Ctrl+" } else { "" }) + (if pk.alt { "Alt+" } else { "" }) + (if pk.shift { "Shift+" } else { "" }) + (if pk.meta { "Meta+" } else { "" })
                  status.val = "Content key: ".to_string() + mods_label + pk.name
                  true
                }
                _ => false
              }
            }),
          
          // Status bar
          @view.View::text("Tab \{selected_tab.val + 1} of \{tabs.length()} | Press arrows to navigate, 1-5 for quick select, 'q' to quit", 
                          color=@core.Color::Gray)
            .margin_top(1.0),
          @view.View::text(status.val, color=@core.Color::Gray)
        ])
          .direction(@view.Direction::Column)
          .spacing(1.0)
          .padding(2.0)
      }
      
      // Run event loop
      @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
        match event {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false  // 'q' to quit
          @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
          _ => false  // Allow default handling unless explicitly blocked
        }
      }, enable_kitty_keyboard=false, debug_mouse=false)
      
      app.cleanup()
    }
  }
}
