///| App - High-level application wrapper for OneBit-TUI
///| Provides a clean, builder-pattern API that hides terminal complexity


pub struct App {
  mut title : String
  mut width : Int
  mut height : Int
  mut background_color : RGBA
  mut enable_mouse : Bool
  mut use_thread : Bool
  renderer : Ref[@ffi.Renderer?]
  key_handlers : Ref[KeyMap[() -> Unit]]
  mut on_update : (App, @ffi.Buffer) -> Unit
  mut on_init : (App) -> Unit
  mut on_cleanup : (App) -> Unit
  mut running : Ref[Bool]
  mut frame_count : Ref[Int]
  mut fps : Int
  // Yoga layout support
  yoga_config : Ref[@wrapper.Config?]
  root_node : Ref[@wrapper.Node?]
  root_ui : Ref[UIBuilder?]
  mut use_yoga : Bool
  mut on_layout : (App, @wrapper.Node) -> Unit
  mut on_build : (App) -> UIBuilder?
}

pub fn App::new() -> App {
  {
    title: "OneBit-TUI App",
    width: 100,
    height: 40,
    background_color: RGBA::new(0.05, 0.05, 0.1, 1.0),
    enable_mouse: true,
    use_thread: true,
    renderer: Ref::new(None),
    key_handlers: Ref::new(KeyMap::new()),
    on_update: fn(_app : App, _buffer : @ffi.Buffer) -> Unit { () },
    on_init: fn(_app : App) -> Unit { () },
    on_cleanup: fn(_app : App) -> Unit { () },
    running: Ref::new(false),
    frame_count: Ref::new(0),
    fps: 60,
    yoga_config: Ref::new(None),
    root_node: Ref::new(None),
    root_ui: Ref::new(None),
    use_yoga: false,
    on_layout: fn(_app : App, _node : @wrapper.Node) -> Unit { () },
    on_build: fn(_app : App) -> UIBuilder? { None }
  }
}

///| Builder methods for configuration

pub fn App::title(self : App, title : String) -> App {
  self.title = title
  self
}

pub fn App::size(self : App, width : Int, height : Int) -> App {
  self.width = width
  self.height = height
  self
}

pub fn App::background(self : App, color : RGBA) -> App {
  self.background_color = color
  self
}

pub fn App::mouse(self : App, enabled : Bool) -> App {
  self.enable_mouse = enabled
  self
}

pub fn App::fps(self : App, fps : Int) -> App {
  self.fps = fps
  self
}

///| Key handling

pub fn App::on_key(self : App, key : Key, handler : () -> Unit) -> App {
  self.key_handlers.val.set(key, handler)
  self
}

pub fn App::on_key_char(self : App, char : Char, handler : () -> Unit) -> App {
  self.on_key(Key::Char(char), handler)
}

pub fn App::on_quit(self : App, handler : () -> Unit) -> App {
  let _ = self.on_key(Key::Char('q'), handler)
  let _ = self.on_key(Key::Escape, handler)
  self
}

///| Event handlers

pub fn App::on_update(self : App, handler : (App, @ffi.Buffer) -> Unit) -> App {
  self.on_update = handler
  self
}

pub fn App::on_init(self : App, handler : (App) -> Unit) -> App {
  self.on_init = handler
  self
}

pub fn App::on_cleanup(self : App, handler : (App) -> Unit) -> App {
  self.on_cleanup = handler
  self
}

///| Yoga layout support

pub fn App::with_yoga(self : App) -> App {
  self.use_yoga = true
  // Initialize Yoga config
  let config = @wrapper.Config::default()
  // config.set_use_web_defaults(true) // Method doesn't exist, skip for now
  self.yoga_config.val = Some(config)
  
  // Create root node
  let root = @wrapper.Node::new_with_config(config)
  self.root_node.val = Some(root)
  self
}

pub fn App::on_build(self : App, builder : (App) -> UIBuilder?) -> App {
  self.on_build = builder
  self
}

pub fn App::on_layout(self : App, handler : (App, @wrapper.Node) -> Unit) -> App {
  self.on_layout = handler
  self
}

///| Get UI builder for constructing UI

pub fn App::ui(self : App) -> UIBuilder {
  box().build()
}

///| Running the app

pub fn App::run(self : App) -> Unit {
  // Initialize renderer if not already done
  match self.renderer.val {
    None => {
      match @ffi.Renderer::new(
        self.width.reinterpret_as_uint(),
        self.height.reinterpret_as_uint()
      ) {
        Some(renderer) => {
          // Configure renderer settings
          renderer.set_background_color(
            self.background_color.r,
            self.background_color.g,
            self.background_color.b,
            self.background_color.a
          )
          
          // Enable mouse if requested
          // @ffi.enable_mouse() // Function doesn't exist, skip for now
          
          self.renderer.val = Some(renderer)
        }
        None => abort("Failed to create renderer")
      }
    }
    Some(_) => ()
  }
  
  // Call init handler
  let _ = self.on_init(self)
  
  // Set running flag
  self.running.val = true
  
  // Main event loop
  let renderer = match self.renderer.val {
    Some(r) => r
    None => abort("Renderer not initialized")
  }
  
  // Setup for FPS limiting
  let frame_duration_ms = 1000 / self.fps
  
  while self.running.val {
    // let frame_start = @ffi.get_time_ms() // Function doesn't exist, skip for now
    
    // Clear and prepare buffer
    renderer.clear_terminal()
    let buffer = renderer.get_next_buffer()
    
    // Handle Yoga layout if enabled
    if self.use_yoga {
      match self.root_node.val {
        Some(root) => {
          // Build UI if builder provided
          match self.on_build(self) {
            Some(ui) => {
              self.root_ui.val = Some(ui)
              // Apply layout to root node
              root.set_width_points(self.width.to_double().to_float())
              root.set_height_points(self.height.to_double().to_float())
              root.calculate_layout(0.0, 0.0, @types.Direction::LTR)
              
              // Notify layout handler
              let _ = self.on_layout(self, root)
            }
            None => ()
          }
        }
        None => ()
      }
    }
    
    // Call update handler
    let _ = self.on_update(self, buffer)
    
    // Process input events
    self.process_input()
    
    // Render frame
    renderer.render()
    self.frame_count.val = self.frame_count.val + 1
    
    // FPS limiting - skip for now since get_time_ms doesn't exist
    // let frame_end = @ffi.get_time_ms()
    // let frame_time = frame_end - frame_start
    // if frame_time < frame_duration_ms {
    //   @ffi.sleep_ms(frame_duration_ms - frame_time)
    // }
  }
  
  // Cleanup
  self.on_cleanup(self)
  
  // Restore terminal
  match self.renderer.val {
    Some(r) => {
      r.clear_terminal()
      // @ffi.disable_mouse() // Function doesn't exist
      // @ffi.restore_terminal() // Function doesn't exist
    }
    None => ()
  }
}

fn App::process_input(self : App) -> Unit {
  // Check for available input
  let event = @ffi.poll_input_event()
  match event {
    @ffi.InputEvent::Key(key_event) => {
      // Convert FFI key event to our Key type
      let key = match key_event {
        @ffi.KeyEvent::Char(c) => Key::Char(c.unsafe_to_char())
        @ffi.KeyEvent::ArrowUp => Key::Up
        @ffi.KeyEvent::ArrowDown => Key::Down
        @ffi.KeyEvent::ArrowLeft => Key::Left
        @ffi.KeyEvent::ArrowRight => Key::Right
        @ffi.KeyEvent::Enter => Key::Enter
        @ffi.KeyEvent::Escape => Key::Escape
        @ffi.KeyEvent::Backspace => Key::Backspace
        @ffi.KeyEvent::Tab => Key::Tab
        @ffi.KeyEvent::Delete => Key::Delete
        @ffi.KeyEvent::Home => Key::Home
        @ffi.KeyEvent::End => Key::End
        @ffi.KeyEvent::PageUp => Key::PageUp
        @ffi.KeyEvent::PageDown => Key::PageDown
        _ => Key::Unknown(0)
      }
      
      // Look up and execute handler
      match self.key_handlers.val.get(key) {
        Some(handler) => handler()
        None => ()
      }
    }
    @ffi.InputEvent::Mouse(_) => {
      // Mouse handling could be added here
    }
    @ffi.InputEvent::None => ()
  }
}

pub fn App::stop(self : App) -> Unit {
  self.running.val = false
}

///| Convenience method to create a simple text app

pub fn text_app(
  text : String,
  ~width : Int = 80,
  ~height : Int = 24
) -> App {
  App::new()
    .size(width, height)
    .on_update(fn(_app, buffer) {
      // Center the text
      let x = (width - text.length()) / 2
      let y = height / 2
      buffer.draw_text(
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        text
      )
    })
    .on_quit(fn() { abort("Quit requested") })
}