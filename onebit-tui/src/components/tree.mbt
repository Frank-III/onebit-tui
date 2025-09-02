pub(all) struct TreeNode {
  mut id : String
  mut label : String
  mut children : Array[TreeNode]
  mut expanded : Bool
  mut selected : Bool
  mut data : Option[Json]
}

pub(all) struct Tree {
  mut root_nodes : Array[TreeNode]
  mut selected_path : Array[Int] // Path to selected node
  mut focused : Bool
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  mut scroll_offset : Int
  mut on_select : Option[(TreeNode) -> Unit]
  mut on_expand : Option[(TreeNode) -> Unit]
  mut show_icons : Bool
}

pub fn TreeNode::new(
  id : String,
  label : String,
  ~children : Array[TreeNode] = [],
  ~expanded : Bool = false,
  ~data : Option[Json] = None
) -> TreeNode {
  TreeNode {
    id,
    label,
    children,
    expanded,
    selected: false,
    data,
  }
}

pub fn Tree::new(
  root_nodes : Array[TreeNode],
  ~on_select : Option[(TreeNode) -> Unit] = None,
  ~on_expand : Option[(TreeNode) -> Unit] = None,
  ~show_icons : Bool = true
) -> Tree {
  Tree {
    root_nodes,
    selected_path: [0],
    focused: false,
    x: 0,
    y: 0,
    width: 0,
    height: 0,
    scroll_offset: 0,
    on_select,
    on_expand,
    show_icons,
  }
}

fn get_visible_nodes(self : Tree) -> Array[(TreeNode, Int, Array[Int])] {
  let mut visible = []
  
  fn traverse(nodes : Array[TreeNode], depth : Int, path : Array[Int]) -> Unit {
    for i, node in nodes {
      let current_path = path + [i]
      visible.push((node, depth, current_path))
      
      if node.expanded && node.children.length() > 0 {
        traverse(node.children, depth + 1, current_path)
      }
    }
  }
  
  traverse(self.root_nodes, 0, [])
  visible
}

fn get_node_at_path(self : Tree, path : Array[Int]) -> Option[TreeNode] {
  let mut current_nodes = self.root_nodes
  let mut node : Option[TreeNode] = None
  
  for i, index in path {
    if index >= 0 && index < current_nodes.length() {
      node = Some(current_nodes[index])
      if i < path.length() - 1 {
        match node {
          Some(n) => current_nodes = n.children
          None => return None
        }
      }
    } else {
      return None
    }
  }
  
  node
}

pub fn render(self : Tree, buffer : Buffer) -> Unit {
  let visible_nodes = self.get_visible_nodes()
  let mut y_offset = 0
  
  // Clear selected state
  for (node, _, _) in visible_nodes {
    node.selected = false
  }
  
  // Mark selected node
  match self.get_node_at_path(self.selected_path) {
    Some(node) => node.selected = true
    None => ()
  }
  
  // Render visible nodes within viewport
  for i = self.scroll_offset; i < visible_nodes.length() && y_offset < self.height; i = i + 1 {
    let (node, depth, path) = visible_nodes[i]
    let is_selected = node.selected
    
    let style = if is_selected && self.focused {
      buffer.theme.get_style("focus")
    } else if is_selected {
      buffer.theme.get_style("selected")
    } else {
      buffer.theme.get_style("normal")
    }
    
    // Draw indentation
    let indent = depth * 2
    buffer.fill_rect(
      self.x,
      self.y + y_offset,
      self.width,
      1,
      ' ',
      style.fg,
      style.bg
    )
    
    // Draw tree lines
    for j = 0; j < depth; j = j + 1 {
      buffer.write_string(
        self.x + j * 2,
        self.y + y_offset,
        "│ ",
        buffer.theme.get_style("border").fg,
        style.bg
      )
    }
    
    // Draw expansion icon
    if node.children.length() > 0 {
      let icon = if node.expanded { "▼ " } else { "▶ " }
      buffer.write_string(
        self.x + indent,
        self.y + y_offset,
        icon,
        style.fg,
        style.bg
      )
    } else if self.show_icons {
      buffer.write_string(
        self.x + indent,
        self.y + y_offset,
        "  ",
        style.fg,
        style.bg
      )
    }
    
    // Draw label
    let label_x = self.x + indent + (if self.show_icons { 2 } else { 0 })
    let max_label_width = self.width - (label_x - self.x)
    let truncated_label = if node.label.length() > max_label_width {
      node.label.substring(0, max_label_width - 3) + "..."
    } else {
      node.label
    }
    
    buffer.write_string(
      label_x,
      self.y + y_offset,
      truncated_label,
      style.fg,
      style.bg
    )
    
    y_offset += 1
  }
}

fn find_prev_visible_node(self : Tree, current_path : Array[Int]) -> Option[Array[Int]] {
  let visible_nodes = self.get_visible_nodes()
  let mut current_index = -1
  
  // Find current node index in visible nodes
  for i, (_, _, path) in visible_nodes {
    let mut same = true
    if path.length() == current_path.length() {
      for j, p in path {
        if p != current_path[j] {
          same = false
          break
        }
      }
      if same {
        current_index = i
        break
      }
    }
  }
  
  if current_index > 0 {
    let (_, _, prev_path) = visible_nodes[current_index - 1]
    Some(prev_path)
  } else {
    None
  }
}

fn find_next_visible_node(self : Tree, current_path : Array[Int]) -> Option[Array[Int]] {
  let visible_nodes = self.get_visible_nodes()
  let mut current_index = -1
  
  // Find current node index in visible nodes
  for i, (_, _, path) in visible_nodes {
    let mut same = true
    if path.length() == current_path.length() {
      for j, p in path {
        if p != current_path[j] {
          same = false
          break
        }
      }
      if same {
        current_index = i
        break
      }
    }
  }
  
  if current_index >= 0 && current_index < visible_nodes.length() - 1 {
    let (_, _, next_path) = visible_nodes[current_index + 1]
    Some(next_path)
  } else {
    None
  }
}

pub fn handle_key(self : Tree, key : String) -> Bool {
  if not(self.focused) {
    return false
  }
  
  match key {
    "ArrowUp" | "k" => {
      match self.find_prev_visible_node(self.selected_path) {
        Some(path) => {
          self.selected_path = path
          self.ensure_visible()
        }
        None => ()
      }
      true
    }
    "ArrowDown" | "j" => {
      match self.find_next_visible_node(self.selected_path) {
        Some(path) => {
          self.selected_path = path
          self.ensure_visible()
        }
        None => ()
      }
      true
    }
    "ArrowRight" | "l" | " " => {
      match self.get_node_at_path(self.selected_path) {
        Some(node) => {
          if node.children.length() > 0 {
            node.expanded = true
            match self.on_expand {
              Some(callback) => callback(node)
              None => ()
            }
          }
        }
        None => ()
      }
      true
    }
    "ArrowLeft" | "h" => {
      match self.get_node_at_path(self.selected_path) {
        Some(node) => {
          if node.expanded {
            node.expanded = false
          } else if self.selected_path.length() > 1 {
            // Move to parent
            self.selected_path = self.selected_path.take(self.selected_path.length() - 1)
            self.ensure_visible()
          }
        }
        None => ()
      }
      true
    }
    "Enter" => {
      match self.get_node_at_path(self.selected_path) {
        Some(node) => {
          match self.on_select {
            Some(callback) => callback(node)
            None => ()
          }
        }
        None => ()
      }
      true
    }
    _ => false
  }
}

pub fn handle_mouse(self : Tree, event : MouseEvent) -> Bool {
  if event.button != MouseButton::Left {
    return false
  }
  
  let visible_nodes = self.get_visible_nodes()
  let clicked_row = event.y - self.y + self.scroll_offset
  
  if clicked_row >= 0 && clicked_row < visible_nodes.length() {
    let (node, depth, path) = visible_nodes[clicked_row]
    let indent = depth * 2
    let icon_x = self.x + indent
    
    // Check if clicked on expansion icon
    if node.children.length() > 0 && 
       event.x >= icon_x && 
       event.x < icon_x + 2 {
      node.expanded = not(node.expanded)
      match self.on_expand {
        Some(callback) => callback(node)
        None => ()
      }
    } else {
      // Select the node
      self.selected_path = path
      self.focused = true
      match self.on_select {
        Some(callback) => callback(node)
        None => ()
      }
    }
    
    return true
  }
  
  false
}

fn ensure_visible(self : Tree) -> Unit {
  let visible_nodes = self.get_visible_nodes()
  let mut selected_index = -1
  
  // Find selected node index
  for i, (node, _, _) in visible_nodes {
    if node.selected {
      selected_index = i
      break
    }
  }
  
  if selected_index >= 0 {
    if selected_index < self.scroll_offset {
      self.scroll_offset = selected_index
    } else if selected_index >= self.scroll_offset + self.height {
      self.scroll_offset = selected_index - self.height + 1
    }
  }
}

pub fn set_position(self : Tree, x : Int, y : Int) -> Unit {
  self.x = x
  self.y = y
}

pub fn set_size(self : Tree, width : Int, height : Int) -> Unit {
  self.width = width
  self.height = height
}

pub fn focus(self : Tree) -> Unit {
  self.focused = true
}

pub fn blur(self : Tree) -> Unit {
  self.focused = false
}

pub fn get_selected_node(self : Tree) -> Option[TreeNode] {
  self.get_node_at_path(self.selected_path)
}