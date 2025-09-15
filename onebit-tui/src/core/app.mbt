///| Simple TUI Application that works without terminal input

///|
/// This is a minimal working implementation
pub struct App {
  renderer : @ffi.Renderer
  mut buffer : @ffi.Buffer
  mut width : Int
  mut height : Int
  mut running : Bool
  // Yoga layout
  yoga_config : @wrapper.Config
  root_node : @wrapper.Node
}

///|
/// Initialize app without requiring terminal session
pub fn App::init() -> App? {
  let (width, height) = @ffi.get_terminal_size()
  match @ffi.Renderer::new(width, height) {
    None => None
    Some(renderer) => {
      // Initialize Yoga
      let config = @wrapper.Config::default()
      let root = @wrapper.Node::new_with_config(config)

      // Setup root node for full screen
      root.set_width(@types.Value::point(width.to_double().to_float()))
      root.set_height(@types.Value::point(height.to_double().to_float()))
      Some(App::{
        renderer,
        buffer: renderer.get_next_buffer(),
        width: width.reinterpret_as_int(),
        height: height.reinterpret_as_int(),
        running: true,
        yoga_config: config,
        root_node: root,
      })
    }
  }
}

///|
/// Clear the screen
pub fn App::clear(self : App, r : Double, g : Double, b : Double) -> Unit {
  self.buffer.clear(r, g, b, 1.0)
}

///|
/// Draw text at position
pub fn App::draw_text(
  self : App,
  text : String,
  x : Int,
  y : Int,
  color : Color,
) -> Unit {
  let (r, g, b) = color_to_rgb(color)
  self.buffer.draw_text(
    text,
    x.reinterpret_as_uint(),
    y.reinterpret_as_uint(),
    fg_r=r,
    fg_g=g,
    fg_b=b,
  )
}

///|
/// Draw a filled rectangle
pub fn App::draw_rect(
  self : App,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  color : Color,
) -> Unit {
  let (r, g, b) = color_to_rgb(color)
  self.buffer.fill_rect(
    x.reinterpret_as_uint(),
    y.reinterpret_as_uint(),
    w.reinterpret_as_uint(),
    h.reinterpret_as_uint(),
    r,
    g,
    b,
    1.0,
  )
}

///|
/// Render the current frame
pub fn App::render(self : App) -> Unit {
  self.renderer.render(force=true)
  self.buffer = self.renderer.get_next_buffer()
}

///|
/// Run a simple render loop
pub fn App::run_once(self : App, draw_fn : (App) -> Unit) -> Unit {
  // Clear screen
  self.clear(0.05, 0.05, 0.1)

  // Call user draw function
  draw_fn(self)

  // Render
  self.render()
}

///|
/// Cleanup
pub fn App::cleanup(self : App) -> Unit {
  self.renderer.destroy()
}
