// Components showcase demo - demonstrates all available components

pub fn run_components_showcase_demo() -> Unit {
  let terminal = @ffi.get_terminal()
  let (width, height) = terminal.get_size()
  
  // Create buffer and theme
  let buffer = Buffer::new(width, height)
  let theme = Theme::default()
  buffer.theme = theme
  
  // Tab selection for different component categories
  let tab_items = [
    @components.TabSelectItem::new("Layout", "layout", false),
    @components.TabSelectItem::new("Input", "input", false),
    @components.TabSelectItem::new("Display", "display", false),
    @components.TabSelectItem::new("Feedback", "feedback", false),
  ]
  
  let tabs = @components.TabSelect::new(tab_items, selected_index=0)
  tabs.set_position(2, 1)
  tabs.set_size(width - 4, 1)
  
  // Create components for each category
  let mut current_category = "layout"
  
  // Layout components
  let flexbox = @components.FlexBox::new(
    direction=@components.FlexDirection::Horizontal,
    justify=@components.JustifyContent::SpaceAround,
    align=@components.AlignItems::Center
  )
  
  let grid = @components.Grid::new(rows=3, cols=3, gap=1)
  
  let splitpane = @components.SplitPane::new(
    orientation=@components.SplitOrientation::Vertical,
    split_position=0.5
  )
  
  // Input components
  let text_input = @components.TextInput::new(
    placeholder="Enter text here...",
    multiline=false
  )
  
  let select_items = [
    @components.SelectItem::new("Option 1", "opt1", false),
    @components.SelectItem::new("Option 2", "opt2", false),
    @components.SelectItem::new("Option 3", "opt3", true),
    @components.SelectItem::new("Option 4", "opt4", false),
  ]
  let select = @components.Select::new(select_items)
  
  let toggle = @components.Toggle::new(
    checked=true,
    label="Enable feature"
  )
  
  // Display components
  let table_data = [
    ["Name", "Age", "City"],
    ["Alice", "25", "New York"],
    ["Bob", "30", "London"],
    ["Charlie", "35", "Tokyo"],
  ]
  let table = @components.Table::new(
    data=table_data,
    has_header=true
  )
  
  let tree_nodes = [
    @components.TreeNode::new(
      "root1",
      "Documents",
      children=[
        @components.TreeNode::new("doc1", "Report.pdf"),
        @components.TreeNode::new("doc2", "Presentation.pptx"),
      ],
      expanded=true
    ),
    @components.TreeNode::new(
      "root2",
      "Pictures",
      children=[
        @components.TreeNode::new("pic1", "vacation.jpg"),
        @components.TreeNode::new("pic2", "family.png"),
      ]
    ),
  ]
  let tree = @components.Tree::new(tree_nodes)
  
  let list_items = [
    @components.ListItem::new("First item", "1"),
    @components.ListItem::new("Second item", "2"),
    @components.ListItem::new("Third item", "3"),
  ]
  let list = @components.List::new(list_items)
  
  // Feedback components
  let progress = @components.ProgressBar::new(
    value=0.65,
    show_percentage=true
  )
  
  let spinner = @components.Spinner::new(
    style=@components.SpinnerStyle::Dots,
    message="Loading..."
  )
  
  let tooltip = @components.Tooltip::new(
    "This is a helpful tooltip that provides additional information",
    position=@components.TooltipPosition::Below
  )
  
  // Modal for demonstration
  let modal = @components.Modal::new(
    title="Example Modal",
    content="This is a modal dialog. Press Escape to close.",
    width=40,
    height=10
  )
  
  // Main rendering loop
  let mut running = true
  let mut show_modal = false
  
  terminal.enable_mouse(true)
  terminal.hide_cursor()
  terminal.clear()
  
  while running {
    buffer.clear(Color::rgb(20, 20, 30))
    
    // Draw main container
    @components.draw_box(
      buffer,
      0, 0, width, height,
      style=@components.BoxStyle::Double,
      title="OpenTUI Components Showcase"
    )
    
    // Render tabs
    tabs.render(buffer)
    
    // Render content based on selected tab
    let content_y = 4
    let content_height = height - 6
    
    match tabs.get_selected_value() {
      "layout" => {
        buffer.write_string(2, content_y, "FlexBox Demo:", theme.get_style("heading").fg, Color::default())
        flexbox.set_position(2, content_y + 2)
        flexbox.set_size(width - 4, 5)
        flexbox.render(buffer)
        
        buffer.write_string(2, content_y + 8, "Grid Demo:", theme.get_style("heading").fg, Color::default())
        grid.set_position(2, content_y + 10)
        grid.set_size(width - 4, 10)
        grid.render(buffer)
      }
      "input" => {
        buffer.write_string(2, content_y, "TextInput:", theme.get_style("heading").fg, Color::default())
        text_input.set_position(2, content_y + 2)
        text_input.set_size(width / 2, 1)
        text_input.render(buffer)
        
        buffer.write_string(2, content_y + 4, "Select:", theme.get_style("heading").fg, Color::default())
        select.set_position(2, content_y + 6)
        select.set_size(width / 2, 10)
        select.render(buffer)
        
        buffer.write_string(width / 2 + 2, content_y + 4, "Toggle:", theme.get_style("heading").fg, Color::default())
        toggle.set_position(width / 2 + 2, content_y + 6)
        toggle.render(buffer)
      }
      "display" => {
        buffer.write_string(2, content_y, "Table:", theme.get_style("heading").fg, Color::default())
        table.set_position(2, content_y + 2)
        table.set_size(width / 2 - 2, 8)
        table.render(buffer)
        
        buffer.write_string(width / 2 + 1, content_y, "Tree:", theme.get_style("heading").fg, Color::default())
        tree.set_position(width / 2 + 1, content_y + 2)
        tree.set_size(width / 2 - 3, 8)
        tree.render(buffer)
        
        buffer.write_string(2, content_y + 11, "List:", theme.get_style("heading").fg, Color::default())
        list.set_position(2, content_y + 13)
        list.set_size(width - 4, 5)
        list.render(buffer)
      }
      "feedback" => {
        buffer.write_string(2, content_y, "Progress Bar:", theme.get_style("heading").fg, Color::default())
        progress.set_position(2, content_y + 2)
        progress.set_size(width - 4, 1)
        progress.render(buffer)
        
        buffer.write_string(2, content_y + 4, "Spinner:", theme.get_style("heading").fg, Color::default())
        spinner.set_position(2, content_y + 6)
        spinner.render(buffer)
        
        buffer.write_string(2, content_y + 8, "Press 'm' to show modal, 't' to show tooltip", theme.get_style("dim").fg, Color::default())
        
        if tooltip.is_visible() {
          tooltip.render(buffer)
        }
      }
      _ => ()
    }
    
    // Show modal if requested
    if show_modal {
      modal.render(buffer)
    }
    
    // Render help text
    buffer.write_string(
      2, height - 2,
      "Arrow keys: Navigate | Tab: Switch tabs | Space/Enter: Select | q: Quit",
      theme.get_style("dim").fg,
      Color::default()
    )
    
    // Render buffer to terminal
    terminal.render_buffer(buffer)
    
    // Handle input
    match terminal.read_key() {
      Some(key) => {
        match key {
          "q" | "Q" => running = false
          "Tab" => {
            let current = tabs.selected_index
            tabs.selected_index = (current + 1) % tabs.items.length()
            current_category = tabs.get_selected_value()
          }
          "m" | "M" => {
            if current_category == "feedback" {
              show_modal = true
              modal.focus()
            }
          }
          "t" | "T" => {
            if current_category == "feedback" {
              if tooltip.is_visible() {
                tooltip.hide()
              } else {
                tooltip.show_at(width / 2 - 20, content_y + 10, 40, 1)
              }
            }
          }
          "Escape" => {
            if show_modal {
              show_modal = false
              modal.blur()
            }
          }
          _ => {
            // Pass key to focused component
            if show_modal {
              modal.handle_key(key)
            } else {
              match current_category {
                "layout" => ()
                "input" => {
                  if text_input.focused {
                    text_input.handle_key(key)
                  } else if select.focused {
                    select.handle_key(key)
                  } else if toggle.focused {
                    toggle.handle_key(key)
                  }
                }
                "display" => {
                  if table.focused {
                    table.handle_key(key)
                  } else if tree.focused {
                    tree.handle_key(key)
                  } else if list.focused {
                    list.handle_key(key)
                  }
                }
                "feedback" => ()
                _ => ()
              }
            }
          }
        }
      }
      None => ()
    }
    
    // Handle mouse events
    match terminal.read_mouse() {
      Some(event) => {
        if show_modal {
          modal.handle_mouse(event)
        } else {
          tabs.handle_mouse(event)
          
          match current_category {
            "input" => {
              text_input.handle_mouse(event)
              select.handle_mouse(event)
              toggle.handle_mouse(event)
            }
            "display" => {
              table.handle_mouse(event)
              tree.handle_mouse(event)
              list.handle_mouse(event)
            }
            _ => ()
          }
        }
      }
      None => ()
    }
    
    // Update animations
    spinner.tick()
    
    // Small delay
    terminal.sleep(16) // ~60 FPS
  }
  
  // Cleanup
  terminal.disable_mouse()
  terminal.show_cursor()
  terminal.clear()
}