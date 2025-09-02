///| Simplest FFI test

fn main {
  println("Testing basic FFI...")
  
  // Direct FFI call
  @ffi.set_cursor_position(10, 5, visible=true)
  
  println("FFI call completed!")
}