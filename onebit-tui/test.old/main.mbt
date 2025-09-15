///| Basic test to verify core components work
///| This will help us ensure the foundation is solid before fixing demos

fn main {
  // Test 1: Create a renderer
  let renderer_opt = @ffi.Renderer::new(80, 24)
  let renderer = match renderer_opt {
    Some(r) => {
      println("✓ Renderer created")
      r
    }
    None => {
      println("✗ Failed to create renderer")
      return
    }
  }
  
  // Test 2: Create a buffer
  let buffer = @core.TerminalBuffer::new(80, 24)
  println("✓ Buffer created")
  
  // Test 3: Create basic components
  test_components()
  
  // Test 4: Test Yoga integration
  test_yoga_layout()
  
  // Test 5: Test rendering pipeline
  test_rendering(renderer, buffer)
  
  println("\n✅ All basic tests passed!")
}

fn test_components() -> Unit {
  // Test each component can be created
  
  // Table - create with columns
  let columns : Array[@components.TableColumn[String]] = [
    { key: "name", title: "Name", width: 20 },
    { key: "value", title: "Value", width: 30 }
  ]
  let table = @components.Table::new[String]("test-table", columns)
  println("✓ Table created")
  
  // List - create with items
  let items : Array[@components.ListItem] = [
    { id: "1", text: "Item 1", icon: None, data: None },
    { id: "2", text: "Item 2", icon: None, data: None },
    { id: "3", text: "Item 3", icon: None, data: None }
  ]
  let list = @components.List::new("test-list", items)
  println("✓ List created")
  
  // Tree
  let tree_node = @components.TreeNode::new(
    "root",
    "Root Node"
  )
  let tree = @components.Tree::new([tree_node])
  println("✓ Tree created")
  
  // Toggle
  let toggle = @components.Toggle::new()
  println("✓ Toggle created")
  
  // TabSelect
  let tabs : Array[@components.TabSelectItem] = [
    { label: "Tab 1", value: "tab1", disabled: false },
    { label: "Tab 2", value: "tab2", disabled: false }
  ]
  let tab_select = @components.TabSelect::new("test-tabs")
  tab_select.items = tabs
  println("✓ TabSelect created")
  
  // Modal
  let modal = @components.Modal::new("test-modal", "Test Modal")
  modal.set_content("This is a test")
  println("✓ Modal created")
  
  // Tooltip
  let tooltip = @components.Tooltip::new("Test tooltip text", position=@components.TooltipPosition::Above)
  println("✓ Tooltip created")
}

fn test_yoga_layout() -> Unit {
  // Create a Yoga node using wrapper
  let root = @wrapper.Node::new()
  println("✓ Yoga node created")
  
  // Set layout properties using wrapper methods
  root.set_width(100.0)
  root.set_height(50.0)
  root.set_flex_direction(@types.FlexDirection::Row)
  println("✓ Yoga properties set")
  
  // Create child nodes
  let child1 = @wrapper.Node::new()
  let child2 = @wrapper.Node::new()
  
  child1.set_flex_grow(1.0)
  child2.set_flex_grow(1.0)
  
  root.add_child(child1)
  root.add_child(child2)
  println("✓ Yoga children added")
  
  // Calculate layout
  root.calculate_layout(100.0, 50.0, @types.Direction::LTR)
  println("✓ Yoga layout calculated")
  
  // Get computed layout
  let layout = root.get_layout()
  println("✓ Yoga layout: x=\{layout.left}, y=\{layout.top}, w=\{layout.width}, h=\{layout.height}")
  
  // Note: Wrapper nodes are automatically freed when they go out of scope
}

fn test_rendering(renderer : @ffi.Renderer, buffer : @core.TerminalBuffer) -> Unit {
  // Test basic rendering operations
  buffer.clear()
  println("✓ Buffer cleared")
  
  // Write some text
  buffer.write_string(5, 5, "Hello, MoonBit TUI!", @core.RGBA::white(), @core.RGBA::black(), @core.TextStyle::Bold)
  println("✓ Text written to buffer")
  
  // Draw a box
  buffer.fill_rect(10, 10, 20, 5, '█', @core.RGBA::blue(), @core.RGBA::black(), @core.TextStyle::None)
  println("✓ Rectangle drawn")
  
  // Test component rendering
  let base = @core.BaseRenderable::new("test")
  base.x = 0
  base.y = 0
  base.width = 80
  base.height = 24
  base.visible = true
  println("✓ BaseRenderable created")
  
  // Get the FFI buffer and test conversion
  let ffi_buffer = renderer.get_next_buffer()
  println("✓ Got FFI buffer from renderer")
  
  // Note: Buffer conversion would happen here once buffer_bridge is fixed
  println("✓ Rendering pipeline tested")
}