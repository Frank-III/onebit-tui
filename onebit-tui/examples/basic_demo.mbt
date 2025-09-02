///| Working demo showcasing OneBit TUI features

fn main() -> Unit {
  println("\n🚀 OneBit TUI - Terminal UI Library for MoonBit\n")
  
  // 1. Basic rendering with colors
  demo_colors()
  
  // 2. Reactive signals
  demo_reactive()
  
  // 3. Animation
  demo_animation()
  
  // 4. UI Layout
  demo_layout()
  
  println("\n✨ OneBit TUI provides modern terminal UI capabilities for MoonBit!")
  println("   Visit: https://github.com/username/onebit-tui")
}

fn demo_colors() -> Unit {
  println("📎 Color System Demo:")
  println("─────────────────────")
  
  // Create a gradient
  let width = 40
  let mut gradient = ""
  for i = 0; i < width; i = i + 1 {
    // Calculate color based on position
    let r = (255.0 * i.to_double() / width.to_double()).to_int()
    let g = (255.0 * (1.0 - i.to_double() / width.to_double())).to_int()
    let b = 128
    
    // ANSI color escape
    gradient = gradient + "\u001b[38;2;\{r};\{g};\{b}m█"
  }
  println(gradient + "\u001b[0m")
  
  // Show named colors
  println("\u001b[31m■ Red\u001b[0m \u001b[32m■ Green\u001b[0m \u001b[34m■ Blue\u001b[0m \u001b[33m■ Yellow\u001b[0m \u001b[35m■ Magenta\u001b[0m \u001b[36m■ Cyan\u001b[0m")
  println("")
}

fn demo_reactive() -> Unit {
  println("⚡ Reactive System Demo:")
  println("─────────────────────")
  
  // Simulate reactive updates
  let mut count = 0
  let mut message = "Initial state"
  
  println("State: count = \{count}, message = \"\{message}\"")
  
  // Update 1
  count = count + 1
  message = "Count incremented"
  println("After update: count = \{count}, message = \"\{message}\"")
  
  // Update 2
  count = count * 2
  message = "Count doubled"
  println("After effect: count = \{count}, message = \"\{message}\"")
  
  println("")
}

fn demo_animation() -> Unit {
  println("🎬 Animation Demo:")
  println("─────────────────")
  
  // Simulate animation frames
  let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
  let progress_width = 20
  
  println("Loading animation:")
  for frame = 0; frame < 5; frame = frame + 1 {
    let spinner = frames[frame % frames.length()]
    let progress = (frame + 1) * 4
    
    let mut bar = "["
    for i = 0; i < progress_width; i = i + 1 {
      if i < progress {
        bar = bar + "="
      } else if i == progress {
        bar = bar + ">"
      } else {
        bar = bar + " "
      }
    }
    bar = bar + "]"
    
    println("\{spinner} \{bar} \{progress * 5}%")
  }
  
  println("")
}

fn demo_layout() -> Unit {
  println("📐 Layout Demo:")
  println("─────────────────")
  
  // Create a simple box layout
  let box_width = 30
  let box_height = 6
  
  // Top border
  let mut top = "┌"
  for i = 0; i < box_width - 2; i = i + 1 {
    top = top + "─"
  }
  top = top + "┐"
  println(top)
  
  // Title
  println("│   📦 OneBit TUI Box        │")
  
  // Separator
  let mut sep = "├"
  for i = 0; i < box_width - 2; i = i + 1 {
    sep = sep + "─"
  }
  sep = sep + "┤"
  println(sep)
  
  // Content
  println("│ • Type-safe components     │")
  println("│ • Reactive state mgmt      │")
  println("│ • Smooth animations        │")
  
  // Bottom border
  let mut bottom = "└"
  for i = 0; i < box_width - 2; i = i + 1 {
    bottom = bottom + "─"
  }
  bottom = bottom + "┘"
  println(bottom)
  
  println("")
}

// Show feature summary
fn show_features() -> Unit {
  let features = [
    ("🎨", "Rich Color System", "RGBA, hex colors, gradients"),
    ("⚡", "Reactive State", "Signals, computed values, effects"),
    ("🎭", "UI Components", "Box, Text, List, Table, Modal"),
    ("🎬", "Animations", "Timeline API, easing, springs"),
    ("📐", "Layout Engine", "Flexbox-style layouts"),
    ("⌨️", "Event Handling", "Keyboard and mouse support"),
    ("🔧", "Developer Experience", "Builder pattern, type safety")
  ]
  
  println("\n📦 OneBit TUI Features:")
  println("══════════════════════════")
  
  for i = 0; i < features.length(); i = i + 1 {
    let (icon, name, desc) = features[i]
    println("\{icon} \{name}")
    println("   └─ \{desc}")
  }
}