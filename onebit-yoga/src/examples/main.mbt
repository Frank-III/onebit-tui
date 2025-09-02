///| Yoga Layout Examples

fn main {
  println("=== Yoga Layout MoonBit Examples ===\n")
  
  // Example 1: Simple row layout
  simple_row_example()
  
  // Example 2: Column with flex
  flex_column_example()
  
  // Example 3: Nested layout
  nested_layout_example()
  
  // Example 4: Using the builder API
  builder_api_example()
}

fn simple_row_example() -> Unit {
  println("1. Simple Row Layout:")
  println("---------------------")
  
  // Create root node
  let root = @wrapper.Node::new()
  root.set_flex_direction(@types.FlexDirection::Row)
  root.set_width_points(300.0)
  root.set_height_points(100.0)
  root.set_padding_all(@types.Value::point(10.0))
  
  // Create three child boxes
  for i = 0; i < 3; i = i + 1 {
    let child = @wrapper.Node::new()
    child.set_width_points(80.0)
    child.set_height_points(50.0)
    child.set_margin(@types.Edge::Right, @types.Value::point(10.0))
    root.add_child(child)
  }
  
  // Calculate layout
  root.calculate_layout(300.0, 100.0, @types.Direction::LTR)
  
  // Print results
  let root_layout = root.get_layout()
  println("Root: \{root_layout}")
  
  for i = 0; i < root.get_child_count(); i = i + 1 {
    match root.get_child(i) {
      Some(child) => {
        let layout = child.get_layout()
        println("Child \{i}: \{layout}")
      }
      None => ()
    }
  }
  println("")
}

fn flex_column_example() -> Unit {
  println("2. Flex Column Layout:")
  println("----------------------")
  
  let root = @wrapper.Node::new()
  root.set_flex_direction(@types.FlexDirection::Column)
  root.set_width_points(200.0)
  root.set_height_points(300.0)
  root.set_justify_content(@types.Justify::SpaceBetween)
  root.set_align_items(@types.Align::Center)
  
  // Header
  let header = @wrapper.Node::new()
  header.set_width_percent(100.0)
  header.set_height_points(50.0)
  root.add_child(header)
  
  // Content (flex grow)
  let content = @wrapper.Node::new()
  content.set_width_percent(90.0)
  content.set_flex_grow(1.0)
  root.add_child(content)
  
  // Footer
  let footer = @wrapper.Node::new()
  footer.set_width_percent(100.0)
  footer.set_height_points(40.0)
  root.add_child(footer)
  
  root.calculate_layout(200.0, 300.0, @types.Direction::LTR)
  
  println("Root: \{root.get_layout()}")
  println("Header: \{header.get_layout()}")
  println("Content: \{content.get_layout()}")
  println("Footer: \{footer.get_layout()}")
  println("")
}

fn nested_layout_example() -> Unit {
  println("3. Nested Layout:")
  println("-----------------")
  
  let root = @wrapper.Node::new()
  root.set_width_points(400.0)
  root.set_height_points(300.0)
  root.set_flex_direction(@types.FlexDirection::Row)
  root.set_padding_all(@types.Value::point(20.0))
  
  // Left sidebar
  let sidebar = @wrapper.Node::new()
  sidebar.set_width_points(100.0)
  sidebar.set_height_percent(100.0)
  sidebar.set_margin(@types.Edge::Right, @types.Value::point(20.0))
  root.add_child(sidebar)
  
  // Main content area
  let main_area = @wrapper.Node::new()
  main_area.set_flex_grow(1.0)
  main_area.set_flex_direction(@types.FlexDirection::Column)
  root.add_child(main_area)
  
  // Add header to main area
  let header = @wrapper.Node::new()
  header.set_height_points(60.0)
  header.set_width_percent(100.0)
  header.set_margin(@types.Edge::Bottom, @types.Value::point(10.0))
  main_area.add_child(header)
  
  // Add content to main area
  let content = @wrapper.Node::new()
  content.set_flex_grow(1.0)
  main_area.add_child(content)
  
  root.calculate_layout(400.0, 300.0, @types.Direction::LTR)
  
  println("Root: \{root.get_layout()}")
  println("Sidebar: \{sidebar.get_layout()}")
  println("Main Area: \{main_area.get_layout()}")
  println("  Header: \{header.get_layout()}")
  println("  Content: \{content.get_layout()}")
  println("")
}

fn builder_api_example() -> Unit {
  println("4. Builder API Example:")
  println("-----------------------")
  
  // Create a centered container with children
  let container = @wrapper.NodeBuilder::center()
    .width(300.0)
    .height(200.0)
    .padding(20.0)
    .build()
  
  // Create a row with spaced items
  let row = @wrapper.NodeBuilder::row()
    .width_percent(100.0)
    .height(50.0)
    .justify(@types.Justify::SpaceBetween)
    .build()
  
  // Add some boxes to the row
  for i = 0; i < 3; i = i + 1 {
    let box = @wrapper.NodeBuilder::new()
      .width(60.0)
      .height(40.0)
      .build()
    row.add_child(box)
  }
  
  container.add_child(row)
  
  // Add a spacer and another element
  let spacer = @wrapper.NodeBuilder::spacer().build()
  container.add_child(spacer)
  
  let bottom_element = @wrapper.NodeBuilder::new()
    .width_percent(80.0)
    .height(30.0)
    .align_self(@types.Align::Center)
    .build()
  container.add_child(bottom_element)
  
  container.calculate_layout(300.0, 200.0, @types.Direction::LTR)
  
  println("Container: \{container.get_layout()}")
  println("Row: \{row.get_layout()}")
  for i = 0; i < row.get_child_count(); i = i + 1 {
    match row.get_child(i) {
      Some(child) => println("  Box \{i}: \{child.get_layout()}")
      None => ()
    }
  }
  println("Bottom Element: \{bottom_element.get_layout()}")
  println("")
}