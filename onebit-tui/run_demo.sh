#!/bin/bash

# Build MoonBit code
echo "Building MoonBit code..."
moon build --target native || exit 1

# Link manually with libraries
echo "Linking with OpenTUI libraries..."
clang \
  onebit-tui/target/native/release/build/demo/demo.o \
  -Lonebit-tui/lib \
  -lopentui_ffi \
  -lopentui \
  -o onebit-tui/demo.exe

# Run the demo
echo "Running demo..."
./onebit-tui/demo.exe