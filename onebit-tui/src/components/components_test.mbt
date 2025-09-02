// Component tests that don't require FFI

test "select_component_basic_functionality" {
  let items = [
    SelectItem::new("Option 1", "opt1", false),
    SelectItem::new("Option 2", "opt2", false),
    SelectItem::new("Option 3 (disabled)", "opt3", true),
  ]
  
  let select = Select::new(items)
  
  // Test initial state
  assert_eq!(select.selected_index, 0)
  assert_eq!(select.focused, false)
  assert_eq!(select.get_selected_value(), "opt1")
  
  // Test keyboard navigation
  select.focus()
  assert_eq!(select.focused, true)
  
  // Move down
  let handled = select.handle_key("ArrowDown")
  assert_eq!(handled, true)
  assert_eq!(select.selected_index, 1)
  assert_eq!(select.get_selected_value(), "opt2")
  
  // Try to move to disabled item (should skip)
  select.handle_key("ArrowDown")
  assert_eq!(select.selected_index, 1) // Should stay at 1
}

test "toggle_component_basic_functionality" {
  let toggle = Toggle::new(checked=false, label="Test Toggle")
  
  // Test initial state
  assert_eq!(toggle.is_checked(), false)
  assert_eq!(toggle.focused, false)
  
  // Test toggle action
  toggle.focus()
  let handled = toggle.handle_key(" ")
  assert_eq!(handled, true)
  assert_eq!(toggle.is_checked(), true)
  
  // Test programmatic change
  toggle.set_checked(false)
  assert_eq!(toggle.is_checked(), false)
}

test "tree_component_basic_functionality" {
  let nodes = [
    TreeNode::new(
      "root",
      "Root Node",
      children=[
        TreeNode::new("child1", "Child 1"),
        TreeNode::new("child2", "Child 2"),
      ]
    )
  ]
  
  let tree = Tree::new(nodes)
  
  // Test initial state
  assert_eq!(tree.selected_path.length(), 1)
  assert_eq!(tree.selected_path[0], 0)
  
  // Test node selection
  tree.focus()
  match tree.get_selected_node() {
    Some(node) => assert_eq!(node.label, "Root Node")
    None => assert_eq!(false, true) // Should not happen
  }
}

test "tab_select_component_basic_functionality" {
  let items = [
    TabSelectItem::new("Tab 1", "tab1", false),
    TabSelectItem::new("Tab 2", "tab2", false),
    TabSelectItem::new("Tab 3 (disabled)", "tab3", true),
  ]
  
  let tabs = TabSelect::new(items)
  
  // Test initial state
  assert_eq!(tabs.selected_index, 0)
  assert_eq!(tabs.get_selected_value(), "tab1")
  
  // Test navigation
  tabs.focus()
  tabs.handle_key("ArrowRight")
  assert_eq!(tabs.selected_index, 1)
  assert_eq!(tabs.get_selected_value(), "tab2")
  
  // Try to move to disabled tab (should skip)
  tabs.handle_key("ArrowRight")
  assert_eq!(tabs.selected_index, 1) // Should stay at 1
}

test "tooltip_component_basic_functionality" {
  let tooltip = Tooltip::new(
    "This is a test tooltip",
    position=TooltipPosition::Above
  )
  
  // Test initial state
  assert_eq!(tooltip.is_visible(), false)
  
  // Test show/hide
  tooltip.show_at(10, 10, 20, 1)
  assert_eq!(tooltip.is_visible(), true)
  
  tooltip.hide()
  assert_eq!(tooltip.is_visible(), false)
  
  // Test text update
  tooltip.set_text("Updated tooltip text")
  assert_eq!(tooltip.text, "Updated tooltip text")
}