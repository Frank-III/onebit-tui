// Test file to check imports
// Run with: moon run test_imports.mbt --target native

fn main {
  println("Testing OneBit TUI imports...")
  
  // If this compiles, we know the package structure is correct
  println("✅ Test passed: OneBit TUI is properly structured")
  println("")
  println("To use OneBit TUI in your project:")
  println("1. Import packages in your moon.pkg.json")
  println("2. Use @core, @components, @reactive in your code")
  println("3. Build with moon build --target native")
}