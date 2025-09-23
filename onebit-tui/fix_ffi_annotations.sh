#!/bin/bash

# Fix FFI annotations by adding #borrow to pointer parameters

echo "Fixing FFI annotations in terminal_ffi.mbt..."

# Fix RendererPtr parameters
sed -i '' 's/\(extern "C" fn [^(]*(\)\(renderer : RendererPtr\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/\(extern "C" fn [^(]*([^,]*, \)\(renderer : RendererPtr\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  renderer : RendererPtr,\)/  #borrow renderer : RendererPtr,/g' src/ffi/terminal_ffi.mbt

# Fix BufferPtr parameters  
sed -i '' 's/\(extern "C" fn [^(]*(\)\(buffer : BufferPtr\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/\(extern "C" fn [^(]*([^,]*, \)\(buffer : BufferPtr\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  buffer : BufferPtr,\)/  #borrow buffer : BufferPtr,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  frame_buffer : BufferPtr,\)/  #borrow frame_buffer : BufferPtr,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  target : BufferPtr,\)/  #borrow target : BufferPtr,/g' src/ffi/terminal_ffi.mbt

# Fix Color parameters (FixedArray pointers)
sed -i '' 's/\(, \)\(color : Color\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/\(, \)\(bg : Color\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt  
sed -i '' 's/\(, \)\(fg : Color\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  color : Color,\)/  #borrow color : Color,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  bg : Color,\)/  #borrow bg : Color,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  fg : Color,\)/  #borrow fg : Color,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  border_color : Color,\)/  #borrow border_color : Color,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  background_color : Color,\)/  #borrow background_color : Color,/g' src/ffi/terminal_ffi.mbt

# Fix Bytes parameters
sed -i '' 's/^\(  style : Bytes,\)/  #borrow style : Bytes,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  title : Bytes,\)/  #borrow title : Bytes,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  data : Bytes,\)/  #borrow data : Bytes,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  pixel_data : Bytes,\)/  #borrow pixel_data : Bytes,/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/\(, \)\(response : Bytes\)/\1#borrow \2/g' src/ffi/terminal_ffi.mbt

# Fix FixedArray parameters
sed -i '' 's/^\(  width : FixedArray\[UInt\],\)/  #borrow width : FixedArray[UInt],/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  height : FixedArray\[UInt\],\)/  #borrow height : FixedArray[UInt],/g' src/ffi/terminal_ffi.mbt
sed -i '' 's/^\(  border_chars : FixedArray\[UInt\],\)/  #borrow border_chars : FixedArray[UInt],/g' src/ffi/terminal_ffi.mbt

echo "Fixing FFI annotations in terminal_input.mbt..."

# Fix terminal_input.mbt
sed -i '' 's/^\(  renderer : RendererPtr,\)/  #borrow renderer : RendererPtr,/g' src/ffi/terminal_input.mbt
sed -i '' 's/\(extern "C" fn [^(]*(\)\(renderer : RendererPtr\)/\1#borrow \2/g' src/ffi/terminal_input.mbt
sed -i '' 's/\(, \)\(renderer : RendererPtr\)/\1#borrow \2/g' src/ffi/terminal_input.mbt
sed -i '' 's/^\(  caps_ptr : TerminalCapabilitiesPtr,\)/  #borrow caps_ptr : TerminalCapabilitiesPtr,/g' src/ffi/terminal_input.mbt
sed -i '' 's/^\(  response : Bytes,\)/  #borrow response : Bytes,/g' src/ffi/terminal_input.mbt
sed -i '' 's/^\(  style : Bytes,\)/  #borrow style : Bytes,/g' src/ffi/terminal_input.mbt
sed -i '' 's/^\(  title : Bytes,\)/  #borrow title : Bytes,/g' src/ffi/terminal_input.mbt
sed -i '' 's/\(, \)\(color : Color\)/\1#borrow \2/g' src/ffi/terminal_input.mbt

echo "Done! Now checking for remaining warnings..."