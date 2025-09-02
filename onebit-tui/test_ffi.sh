#!/bin/bash

# Simple FFI test script

echo "Building OneBit-TUI FFI test..."

# Clean
rm -rf test_build
mkdir -p test_build

# Write a minimal MoonBit test
cat > test_build/test.mbt << 'EOF'
fn main {
  println("Testing OneBit-TUI FFI...")
  
  // Test 1: Set cursor position (simple FFI call)
  @moonbit-community/onebit-tui/ffi.set_cursor_position(10, 10, visible=false)
  println("✓ Cursor position set")
  
  // Test 2: Try to create renderer
  match @moonbit-community/onebit-tui/ffi.Renderer::new(80, 24) {
    Some(r) => {
      println("✓ FFI Renderer created!")
      r.destroy()
      println("✓ FFI Renderer destroyed!")
    }
    None => {
      println("✗ Failed to create FFI renderer")
    }
  }
  
  println("Test complete!")
}
EOF

# Build it
echo "Compiling test..."
moon build-exe \
  --target native \
  -o test_build/test.exe \
  test_build/test.mbt \
  --link-opt "-L/Users/frankmac/projects/learn_ts/opentui/onebit-tui/lib -lopentui_ffi -lopentui" \
  2>&1

if [ -f test_build/test.exe ]; then
  echo "Running test..."
  DYLD_LIBRARY_PATH=/Users/frankmac/projects/learn_ts/opentui/onebit-tui/lib ./test_build/test.exe
else
  echo "Failed to build test"
fi