///|
/// Main Demo Runner - Shows OneBit TUI features
/// Demonstrates core rendering capabilities

fn main {
  // Check if we should run interactive or static demo
  // For now, we'll show both options
  
  println("\n╔══════════════════════════════════════════════════════╗")
  println("║          OneBit TUI - Demo Selector                   ║")
  println("║          MoonBit Terminal UI Framework                ║")
  println("╚══════════════════════════════════════════════════════╝\n")
  
  println("Running demos...\n")
  println("1. Static Demo (renders once)")
  println("------------------------")
  
  // Run the simple static demo
  simple_main()
  
  println("\n2. New Architecture Demo")
  println("------------------------")
  println("Demonstrating flexible component composition...\n")
  
  // Run the architecture demo
  architecture_demo()
  
  println("\n3. Clean API Demo")
  println("------------------------")
  println("Demonstrating the new declarative API...\n")
  
  // Run the clean API demo
  clean_api_demo()
  
  println("\n4. Architecture Demo with FFI")
  println("------------------------")
  println("Using FFI for hardware-accelerated rendering...\n")
  
  // Run FFI demo
  architecture_demo_ffi()
  
  println("\n5. Clean API with FFI")
  println("------------------------")
  println("Best of both worlds: Clean API + Fast Rendering...\n")
  
  // Run clean API with FFI
  clean_api_ffi_demo()
  
  println("\n6. FFI-First Architecture Demo")
  println("------------------------")
  println("Demonstrating our FFI-first approach...\n")
  
  // Run FFI-first demo
  ffi_first_demo()
  
  println("\nOneBit TUI demonstrated successfully!")
}