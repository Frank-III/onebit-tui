///| Core renderer using OpenTUI FFI

pub struct Renderer {
  ffi : @ffi.Renderer
  buffer : @ffi.Buffer
  width : Int
  height : Int
}

/// Create a new renderer
pub fn Renderer::new(width : Int, height : Int) -> Renderer? {
  match @ffi.Renderer::new(width.reinterpret_as_uint(), height.reinterpret_as_uint()) {
    None => None
    Some(ffi) => {
      ffi.set_background_color(0.05, 0.05, 0.1, 1.0)
      let buffer = ffi.get_next_buffer()
      Some({ ffi, buffer, width, height })
    }
  }
}

/// Clear the screen
pub fn Renderer::clear(self : Renderer) -> Unit {
  self.buffer.clear(0.05, 0.05, 0.1, 1.0)
}

/// Render a view using FFI
pub fn Renderer::render_view(self : Renderer, view : View) -> Unit {
  // Create FFI render context
  let ctx = FFIRenderContext::{
    buffer: self.buffer,
    bounds: Rect::new(0, 0, self.width, self.height)
  }
  
  // Render directly to FFI buffer
  view.render_ffi(ctx)
  
  // Render frame
  self.ffi.render(force=true)
}

/// Render the current frame
pub fn Renderer::present(self : Renderer) -> Unit {
  self.ffi.render(force=true)
}

/// Draw text directly (for status messages etc)
pub fn Renderer::draw_text(
  self : Renderer,
  text : String,
  x : Int,
  y : Int,
  color~ : RGBA = RGBA::white(),
  bg_color~ : RGBA? = None,
  bold~ : Bool = false
) -> Unit {
  match bg_color {
    None => {
      self.buffer.draw_text(
        text,
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        fg_r=color.r,
        fg_g=color.g,
        fg_b=color.b,
        bold=bold
      )
    }
    Some(bg) => {
      self.buffer.draw_text(
        text,
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        fg_r=color.r,
        fg_g=color.g,
        fg_b=color.b,
        bg_r=Some(bg.r),
        bg_g=Some(bg.g),
        bg_b=Some(bg.b),
        bold=bold
      )
    }
  }
}

/// Fill a rectangle
pub fn Renderer::fill_rect(
  self : Renderer,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  color : RGBA
) -> Unit {
  self.buffer.fill_rect(
    x.reinterpret_as_uint(),
    y.reinterpret_as_uint(),
    width.reinterpret_as_uint(),
    height.reinterpret_as_uint(),
    color.r,
    color.g,
    color.b,
    color.a
  )
}

/// Clean up resources
pub fn Renderer::destroy(self : Renderer) -> Unit {
  self.ffi.destroy()
}

/// Global FFI terminal functions

/// Setup terminal for TUI mode
pub fn setup_terminal() -> Renderer? {
  Renderer::new(80, 24)
}

/// Restore terminal to normal mode
pub fn restore_terminal(renderer : Renderer) -> Unit {
  renderer.destroy()
}