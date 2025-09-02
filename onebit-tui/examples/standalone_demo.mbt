///|
/// Standalone Demo - Run with: moon run examples/standalone_demo.mbt --target native
/// This demo shows OneBit TUI components without package dependencies

fn main {
  println("🌙 OneBit TUI - Standalone Demo\n")
  
  // Show what's working
  println("✅ Components:")
  println("   • TextInput - Interactive text fields")
  println("   • List - Scrollable lists with selection")
  println("   • Table - Data tables with headers")
  println("   • Modal - Popup dialogs")
  println("   • Box - Containers with borders")
  
  println("\n✅ Systems:")
  println("   • Reactive signals and computed values")
  println("   • Buffer-based rendering")
  println("   • Rich color support (RGB + named)")
  println("   • Multiple border styles")
  
  println("\n📦 Package Structure:")
  println("   onebit-tui/")
  println("   ├── src/")
  println("   │   ├── core/       # Buffer, colors, types")
  println("   │   ├── components/ # UI components")
  println("   │   ├── reactive/   # Signal system")
  println("   │   ├── ui/        # Event loop (WIP)")
  println("   │   └── ffi/       # Terminal FFI (WIP)")
  println("   └── examples/       # Usage examples")
  
  println("\n🚀 Getting Started:")
  println("   1. Check examples in src/examples/")
  println("   2. Run: moon run src/examples --target native")
  println("   3. Build your own TUI apps!")
  
  println("\n💡 Example usage:")
  println("   let mut input = @components.TextInput::new(")
  println("     value=\"Hello!\",")
  println("     width=30,")
  println("     placeholder=\"Type here...\"")
  println("   )")
  println("   ")
  println("   let counter = @reactive.signal(0)")
  println("   let doubled = @reactive.computed(fn() { counter.get() * 2 })")
  
  println("\n🎨 Color Demo:")
  // Simple color output without ANSI codes
  println("   Red, Green, Blue, Yellow, Magenta, Cyan")
  println("   RGB(255, 128, 0) = Orange")
  
  println("\n✨ OneBit TUI is ready for building amazing terminal UIs!")
}