#!/bin/bash

echo "Building OneBit TUI Examples..."
echo "================================"

# Build all packages
moon build --target native

if [ $? -eq 0 ]; then
  echo "✅ Build successful!"
  echo ""
  echo "Select a demo to run:"
  echo "1. Basic Components Demo"
  echo "2. Reactive State Demo"
  echo "3. UI Builder API Demo"
  echo "4. Layout Systems Demo" 
  echo "5. Dashboard Demo"
  echo ""
  
  read -p "Enter choice (1-5): " choice
  
  case $choice in
    1)
      echo "Running Basic Demo..."
      ./target/native/release/build/examples/01_basic_demo.exe
      ;;
    2)
      echo "Running Reactive Demo..."
      ./target/native/release/build/examples/02_reactive_demo.exe
      ;;
    3)
      echo "Running UI Builder Demo..."
      ./target/native/release/build/examples/03_ui_builder_demo.exe
      ;;
    4)
      echo "Running Layout Demo..."
      ./target/native/release/build/examples/04_layout_demo.exe
      ;;
    5)
      echo "Running Dashboard Demo..."
      ./target/native/release/build/examples/05_dashboard_demo.exe
      ;;
    *)
      echo "Invalid choice"
      ;;
  esac
else
  echo "❌ Build failed. Check the errors above."
fi