///|
/// Demo showing how widgets use Yoga for layout
pub fn test_yoga_layout() -> Unit {
  println("=== Yoga Layout Demo with Widgets ===\n")

  // Create some state
  let selected_item = Ref::new("")
  let input_value = Ref::new("")
  let progress_value = Ref::new(0.65)

  // Create widgets
  let title = @widget.Text::heading("Yoga Layout Demo")
  let subtitle = @widget.Text::caption("Demonstrating flex layout with widgets")

  // Create a list widget
  let items = ["Dashboard", "Profile", "Settings", "Reports", "Analytics"]
  let list = @widget.List::new(items, fn(item, selected) {
      if selected {
        "→ \{item}"
      } else {
        "  \{item}"
      }
    })
    .visible_items(5)
    .on_select(fn(item, _idx) { selected_item.val = item })

  // Create buttons
  let button1 = @widget.Button::primary("Submit", fn() {
    println("Submit pressed")
  })
  let button2 = @widget.Button::secondary("Cancel", fn() {
    println("Cancel pressed")
  })

  // Create input
  let input = @widget.TextInput::new(input_value)
    .placeholder("Enter your name...")
    .width(30.0)

  // Create progress bar
  let progress = @widget.ProgressBar::new(progress_value.val)
    .width(40.0)
    .label("Processing")
    .with_style(@widget.ProgressStyle::simple())
  println("Building layout with Yoga properties...")

  // Build a complex layout using Views with Yoga properties

  // Sidebar with list (fixed width, full height)
  let sidebar = @view.View::container_views([
      @widget.Text::body("Navigation").render(),
      list.render(),
    ])
    .direction(@view.Direction::Column)
    .width(25.0) // Fixed width
    .padding(1.0)
    .background(@core.Color::Black)

  // Main content area (flex: 1 to take remaining space)
  let main_content = @view.View::container_views([
      // Header
      @view.View::container_views([title.render(), subtitle.render()])
      .direction(@view.Direction::Column)
      .padding(1.0),

      // Form section
      @view.View::container_views([
        @widget.Text::body("Form Section").render(),
        input.render(),
        progress.render(),
      ])
      .direction(@view.Direction::Column)
      .spacing(1.0)
      .padding(2.0)
      .margin(1.0),

      // Button row (aligned to bottom)
      @view.View::container_views([button1.render(), button2.render()])
      .direction(@view.Direction::Row)
      .spacing(2.0)
      .align_items(@types.Align::Center)
      .justify_content(@types.Justify::FlexEnd)
      .padding(1.0),
    ])
    .direction(@view.Direction::Column)
    .flex(1.0) // Take remaining space
    .justify_content(@types.Justify::SpaceBetween)

  // Root container with horizontal layout
  let root_layout = @view.View::container_views([sidebar, main_content])
    .direction(@view.Direction::Row)
    .width(80.0) // Total width
    .height(24.0) // Total height
  println("\nLayout Structure:")
  println(
    "┌─────────────────────────────────────────────┐",
  )
  println("│ Root (Row, 80x24)                          │")
  println("│ ├─ Sidebar (Column, width=25)              │")
  println("│ │  ├─ Navigation title                     │")
  println("│ │  └─ List widget                          │")
  println("│ └─ Main Content (Column, flex=1)           │")
  println("│    ├─ Header (Column)                      │")
  println("│    ├─ Form (Column, spacing=1)             │")
  println("│    └─ Buttons (Row, justify=end)           │")
  println(
    "└─────────────────────────────────────────────┘",
  )
  println("\nYoga Properties Used:")
  println("- FlexDirection: Row and Column")
  println("- Flex: 1.0 for main content (takes remaining space)")
  println("- Width: Fixed for sidebar (25), total (80)")
  println("- Height: Fixed total (24)")
  println("- Spacing: Gap between children")
  println("- Padding: Internal spacing")
  println("- Margin: External spacing")
  println("- JustifyContent: SpaceBetween, FlexEnd")
  println("- AlignItems: Center")

  // Calculate layout with Yoga
  println("\nCalculating layout with Yoga...")
  let yoga_root = @layout.calculate_layout(root_layout, 80.0, 24.0)

  // Get calculated positions
  println("\nCalculated Layout Results:")
  println(
    "- Root position: (\{yoga_root.layout_left()}, \{yoga_root.layout_top()})",
  )
  println(
    "- Root size: \{yoga_root.layout_width()} x \{yoga_root.layout_height()}",
  )

  // Access child nodes
  let sidebar_node = yoga_root.get_child(0).unwrap()
  println(
    "- Sidebar position: (\{sidebar_node.layout_left()}, \{sidebar_node.layout_top()})",
  )
  println(
    "- Sidebar size: \{sidebar_node.layout_width()} x \{sidebar_node.layout_height()}",
  )
  let main_node = yoga_root.get_child(1).unwrap()
  println(
    "- Main content position: (\{main_node.layout_left()}, \{main_node.layout_top()})",
  )
  println(
    "- Main content size: \{main_node.layout_width()} x \{main_node.layout_height()}",
  )
  println("\n=== Yoga Layout Demo Complete ===")
  println("✓ Widgets render to Views")
  println("✓ Views have Yoga layout properties")
  println("✓ Layout engine converts Views to Yoga nodes")
  println("✓ Yoga calculates final positions and sizes")
}
