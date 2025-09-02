///| Tests for Yoga wrapper

test "create node" {
  let node = Node::new()
  assert_true(node.get_child_count() == 0)
}

test "add and remove children" {
  let parent = Node::new()
  let child1 = Node::new()
  let child2 = Node::new()
  
  parent.add_child(child1)
  assert_eq(parent.get_child_count(), 1)
  
  parent.add_child(child2)
  assert_eq(parent.get_child_count(), 2)
  
  parent.remove_child(child1)
  assert_eq(parent.get_child_count(), 1)
}

test "set dimensions" {
  let node = Node::new()
  
  // Test point values
  node.set_width(@types.Value::point(100.0))
  node.set_height(@types.Value::point(50.0))
  
  // Test percent values
  node.set_width(@types.Value::percent(50.0))
  node.set_height(@types.Value::percent(100.0))
  
  // Test auto
  node.set_width(@types.Value::auto())
  node.set_height(@types.Value::auto())
  
  // Should not crash
  assert_true(true)
}

test "flex properties" {
  let node = Node::new()
  
  node.set_flex(1.0)
  node.set_flex_grow(2.0)
  node.set_flex_shrink(0.5)
  node.set_flex_basis(100.0)
  
  // Should not crash
  assert_true(true)
}

test "builder pattern" {
  let node = NodeBuilder::row()
    .width(200.0)
    .height(100.0)
    .padding(10.0)
    .margin(5.0)
    .justify(@types.Justify::Center)
    .align_items(@types.Align::Center)
    .build()
  
  assert_eq(node.get_child_count(), 0)
}

test "builder with children" {
  let child1 = NodeBuilder::new().width(50.0).height(50.0).build()
  let child2 = NodeBuilder::new().width(50.0).height(50.0).build()
  
  let parent = NodeBuilder::column()
    .width(100.0)
    .height(200.0)
    .child(child1)
    .child(child2)
    .build()
  
  assert_eq(parent.get_child_count(), 2)
}

test "calculate layout" {
  let root = Node::new()
  root.set_width_points(100.0)
  root.set_height_points(100.0)
  
  // Should not crash
  root.calculate_layout(100.0, 100.0, @types.Direction::LTR)
  let layout = root.get_layout()
  
  // With our mock implementation, we expect specific values
  assert_eq(layout.width, 100.0)
  assert_eq(layout.height, 100.0)
}