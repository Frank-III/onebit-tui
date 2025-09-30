///|
/// Simple test to debug dropdown visibility
fn main_dropdown_test() -> Unit {
  let app = @core.App::init()
  match app {
    None => println("Failed to initialize app")
    Some(app) => {
      // Simple state to control dropdown
      let is_open = Ref::new(false)
      let selected_idx = Ref::new(0)
      let options = ["Red", "Green", "Blue"]
      
      fn build_ui() -> @view.View {
        println("Building UI - is_open: \{is_open.val}, selected: \{selected_idx.val}")
        
        let main_box = @view.View::text("Select: \{options[selected_idx.val]} ▼", 
                                        color=@core.Color::White)
          .padding(1.0)
          .border(@view.BorderStyle::Single)
          .focusable()
          .on_key(fn(key) {
            match key {
              @ffi.KeyEvent::Enter | @ffi.KeyEvent::Char(32) => {
                println("Toggle dropdown - was: \{is_open.val}")
                is_open.val = not(is_open.val)
                println("Toggle dropdown - now: \{is_open.val}")
                true
              }
              @ffi.KeyEvent::ArrowUp => {
                if is_open.val && selected_idx.val > 0 {
                  selected_idx.val = selected_idx.val - 1
                  true
                } else {
                  false
                }
              }
              @ffi.KeyEvent::ArrowDown => {
                if is_open.val && selected_idx.val < options.length() - 1 {
                  selected_idx.val = selected_idx.val + 1
                  true
                } else if not(is_open.val) {
                  is_open.val = true
                  true
                } else {
                  false
                }
              }
              @ffi.KeyEvent::Escape => {
                if is_open.val {
                  is_open.val = false
                  true
                } else {
                  false
                }
              }
              _ => false
            }
          })
        
        // Build UI based on state
        if is_open.val {
          println("Rendering with dropdown")
          // When open, show dropdown
          let dropdown_items : Array[@view.View] = []
          for i = 0; i < options.length(); i = i + 1 {
            let prefix = if i == selected_idx.val { "> " } else { "  " }
            let bg = if i == selected_idx.val { 
              Some(@core.Color::Blue) 
            } else { 
              None 
            }
            let mut item = @view.View::text(prefix + options[i], color=@core.Color::White)
            match bg {
              Some(color) => item = item.background(color)
              None => ()
            }
            dropdown_items.push(item)
          }
          
          // Create a bright colored dropdown for visibility - TEST WITHOUT ABSOLUTE
          let dropdown = @view.View::container_views(dropdown_items)
            .direction(@view.Direction::Column)
            .border(@view.BorderStyle::Double, color=@core.Color::Yellow)  // Bright yellow border
            .background(@core.rgb(0, 50, 0))  // Dark green background
            // .position(@view.Position::Absolute)  // DISABLED FOR TEST
            // .top(3.0)
            // .left(0.0)
            .width(20.0)  // Explicit width
            .padding(1.0)
          
          @view.View::container_views([
            @view.View::text("Dropdown Test", color=@core.Color::Cyan),
            @view.View::text("State: OPEN", color=@core.Color::Green),
            // Show both vertically to test if dropdown renders at all
            @view.View::container_views([main_box, dropdown])
              .direction(@view.Direction::Column)  // Changed to Column for test
              .spacing(1.0),
          ])
            .direction(@view.Direction::Column)
            .spacing(1.0)
            .padding(2.0)
        } else {
          println("Rendering without dropdown")
          // When closed, just show the select box
          @view.View::container_views([
            @view.View::text("Dropdown Test", color=@core.Color::Cyan),
            @view.View::text("State: CLOSED", color=@core.Color::Red),
            main_box,
          ])
            .direction(@view.Direction::Column)
            .spacing(1.0)
            .padding(2.0)
        }
      }
      
      // Run event loop
      @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
        match event {
          @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false  // 'q' to quit
          _ => false
        }
      })
      
      app.cleanup()
    }
  }
}

