///| File Explorer Demo
///| Shows a file system browser with tree view, split panes, and file preview

struct FileNode {
  name : String
  path : String
  is_directory : Bool
  mut expanded : Bool
  children : FixedArray[FileNode]?
  size : Int
  modified : String
}

struct FileExplorerState {
  mut selected_index : Int
  mut scroll_offset : Int
  mut current_path : String
  files : FixedArray[FileNode]
  mut preview_content : String
  split_position : Double
  mut show_hidden : Bool
  mut sort_by : SortMode
  mut view_mode : ViewMode
}

enum SortMode {
  Name
  Size
  Modified
  Type
} derive(Eq)

enum ViewMode {
  List
  Tree
  Grid
} derive(Eq)

pub fn run_file_explorer_demo() -> Unit {
  println("=== OneBit-TUI File Explorer Demo ===")
  println("Controls:")
  println("  ↑/↓     - Navigate files")
  println("  →/Enter - Open folder/file")
  println("  ←       - Go back")
  println("  Space   - Toggle folder")
  println("  h       - Toggle hidden files")
  println("  s       - Change sort mode")
  println("  v       - Change view mode")
  println("  Tab     - Switch panes")
  println("  q/ESC   - Quit")
  println("")
  println("Press any key to start...")
  
  // Create terminal session
  match @ffi.TerminalSession::new(
    raw_mode=true,
    mouse=true,
    mouse_movement=false,
    resize_detection=true
  ) {
    None => {
      println("Failed to initialize terminal session")
      return
    }
    Some(session) => {
      let (width, height) = @ffi.get_terminal_size()
      
      // Initialize state with sample file system
      let state = FileExplorerState::{
        selected_index: 0,
        scroll_offset: 0,
        current_path: "/home/user",
        files: create_sample_filesystem(),
        preview_content: "",
        split_position: 0.3,
        show_hidden: false,
        sort_by: SortMode::Name,
        view_mode: ViewMode::Tree,
      }
      
      // Initialize renderer
      match @ffi.Renderer::new(width, height) {
        None => {
          session.cleanup()
          println("Failed to initialize renderer")
          return
        }
        Some(renderer) => {
          run_explorer(renderer, state)
          
          // Clean up
          renderer.destroy()
          session.cleanup()
          
          println("\nFile Explorer demo completed!")
        }
      }
    }
  }
}

fn run_explorer(renderer : @ffi.Renderer, state : FileExplorerState) -> Unit {
  renderer.set_use_thread(true)
  renderer.set_background_color(0.05, 0.05, 0.1, 1.0)
  
  let mut running = true
  
  while running {
    // Poll for events
    let event = @ffi.poll_input_event()
    
    // Handle input
    match event {
      @ffi.InputEvent::Key(key) => {
        match key {
          @ffi.KeyEvent::Escape => running = false
          @ffi.KeyEvent::Char(113) => running = false  // 'q'
          
          @ffi.KeyEvent::ArrowUp => {
            if state.selected_index > 0 {
              state.selected_index = state.selected_index - 1
              update_scroll(state)
              update_preview(state)
            }
          }
          
          @ffi.KeyEvent::ArrowDown => {
            let max_index = state.files.length() - 1
            if state.selected_index < max_index {
              state.selected_index = state.selected_index + 1
              update_scroll(state)
              update_preview(state)
            }
          }
          
          @ffi.KeyEvent::ArrowRight | @ffi.KeyEvent::Enter => {
            if state.selected_index < state.files.length() {
              let file = state.files[state.selected_index]
              if file.is_directory {
                // Expand/collapse in tree view, or navigate in list view
                if state.view_mode == ViewMode::Tree {
                  file.expanded = not(file.expanded)
                } else {
                  navigate_to(state, file.path)
                }
              } else {
                // Open file preview
                update_preview(state)
              }
            }
          }
          
          @ffi.KeyEvent::ArrowLeft => {
            // Go to parent directory or collapse folder
            if state.view_mode == ViewMode::Tree && state.selected_index < state.files.length() {
              let file = state.files[state.selected_index]
              if file.is_directory && file.expanded {
                file.expanded = false
              } else {
                navigate_to_parent(state)
              }
            } else {
              navigate_to_parent(state)
            }
          }
          
          @ffi.KeyEvent::Char(32) => {  // Space key
            // Toggle folder expansion in tree view
            if state.view_mode == ViewMode::Tree && state.selected_index < state.files.length() {
              let file = state.files[state.selected_index]
              if file.is_directory {
                file.expanded = not(file.expanded)
              }
            }
          }
          
          @ffi.KeyEvent::Char(104) => {  // 'h'
            state.show_hidden = not(state.show_hidden)
            refresh_files(state)
          }
          
          @ffi.KeyEvent::Char(115) => {  // 's'
            // Cycle sort mode
            state.sort_by = match state.sort_by {
              SortMode::Name => SortMode::Size
              SortMode::Size => SortMode::Modified
              SortMode::Modified => SortMode::Type
              SortMode::Type => SortMode::Name
            }
            sort_files(state)
          }
          
          @ffi.KeyEvent::Char(118) => {  // 'v'
            // Cycle view mode
            state.view_mode = match state.view_mode {
              ViewMode::List => ViewMode::Tree
              ViewMode::Tree => ViewMode::Grid
              ViewMode::Grid => ViewMode::List
            }
          }
          
          @ffi.KeyEvent::Tab => {
            // Switch focus between panes (not implemented in this demo)
            ()
          }
          
          _ => ()
        }
      }
      
      @ffi.InputEvent::MouseDown(x, y, _button) => {
        // Handle file selection by click
        handle_mouse_click(state, x, y)
      }
      
      @ffi.InputEvent::Resize(new_width, new_height) => {
        renderer.resize(new_width, new_height)
      }
      
      _ => ()
    }
    
    // Render UI
    render_file_explorer(renderer, state)
  }
}

fn render_file_explorer(renderer : @ffi.Renderer, state : FileExplorerState) -> Unit {
  let buffer = renderer.get_next_buffer()
  buffer.clear(0.05, 0.05, 0.1, 1.0)
  
  let (width, height) = @ffi.get_terminal_size()
  
  // Draw title bar
  draw_title_bar(buffer, state, width)
  
  // Calculate pane dimensions
  let left_width = (width.to_double() * state.split_position).to_int()
  let right_width = width.to_int() - left_width - 1
  
  // Draw file tree/list pane
  draw_file_pane(buffer, state, 0, 2, left_width.to_uint(), height - 3_U)
  
  // Draw divider
  draw_vertical_divider(buffer, left_width, 2, height - 3_U)
  
  // Draw preview pane
  draw_preview_pane(buffer, state, left_width + 1, 2, right_width.to_uint(), height - 3_U)
  
  // Draw status bar
  draw_status_bar(buffer, state, width, height)
  
  renderer.render(force=false)
}

fn draw_title_bar(buffer : @ffi.Buffer, state : FileExplorerState, width : UInt) -> Unit {
  buffer.fill_rect(0_U, 0_U, width, 2_U, 0.1, 0.1, 0.2, 1.0)
  
  // Draw path breadcrumb
  buffer.draw_text(
    "📁 " + state.current_path,
    2_U, 0_U,
    fg_r=0.8, fg_g=0.8, fg_b=1.0,
    bold=true
  )
  
  // Draw view mode and sort info
  let info = "View: " + view_mode_string(state.view_mode) + 
             " | Sort: " + sort_mode_string(state.sort_by) +
             (if state.show_hidden { " | [Hidden]" } else { "" })
  
  let info_x = width - info.length().to_uint() - 2_U
  buffer.draw_text(
    info,
    info_x, 0_U,
    fg_r=0.6, fg_g=0.6, fg_b=0.8
  )
}

fn draw_file_pane(buffer : @ffi.Buffer, state : FileExplorerState, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  // Draw border
  draw_box_border(buffer, x, y, width, height, "Files")
  
  // Draw file list based on view mode
  match state.view_mode {
    ViewMode::Tree => draw_tree_view(buffer, state, x + 1, y + 1, width - 2_U, height - 2_U)
    ViewMode::List => draw_list_view(buffer, state, x + 1, y + 1, width - 2_U, height - 2_U)
    ViewMode::Grid => draw_grid_view(buffer, state, x + 1, y + 1, width - 2_U, height - 2_U)
  }
}

fn draw_tree_view(buffer : @ffi.Buffer, state : FileExplorerState, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  let mut row = 0
  let mut file_index = 0
  
  fn draw_tree_node(node : FileNode, indent : Int) -> Unit {
    if row >= state.scroll_offset && row < state.scroll_offset + height.to_int() {
      let display_row = row - state.scroll_offset
      let is_selected = file_index == state.selected_index
      
      // Draw selection highlight
      if is_selected {
        buffer.fill_rect(
          x.to_uint(), (y + display_row).to_uint(), width, 1_U,
          0.2, 0.3, 0.5, 1.0
        )
      }
      
      // Draw indent and tree lines
      let mut indent_str = ""
      for i = 0; i < indent; i = i + 1 {
        indent_str = indent_str + "  "
      }
      
      // Draw expand/collapse indicator for directories
      let prefix = if node.is_directory {
        if node.expanded { "▼ " } else { "▶ " }
      } else {
        "  "
      }
      
      // Draw icon and name
      let icon = if node.is_directory { "📁" } else { get_file_icon(node.name) }
      let text = indent_str + prefix + icon + " " + node.name
      
      buffer.draw_text(
        text,
        x.to_uint(), (y + display_row).to_uint(),
        fg_r=if is_selected { 1.0 } else { 0.8 },
        fg_g=if is_selected { 1.0 } else { 0.8 },
        fg_b=if is_selected { 1.0 } else { 0.8 },
        bold=is_selected
      )
    }
    
    row = row + 1
    file_index = file_index + 1
    
    // Draw children if expanded
    if node.is_directory && node.expanded {
      match node.children {
        Some(children) => {
          for i = 0; i < children.length(); i = i + 1 {
            draw_tree_node(children[i], indent + 1)
          }
        }
        None => ()
      }
    }
  }
  
  // Draw all root nodes
  for i = 0; i < state.files.length(); i = i + 1 {
    draw_tree_node(state.files[i], 0)
  }
}

fn draw_list_view(buffer : @ffi.Buffer, state : FileExplorerState, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  // Draw column headers
  buffer.draw_text("Name", x.to_uint(), y.to_uint(), fg_r=0.5, fg_g=0.5, fg_b=0.7, bold=true)
  buffer.draw_text("Size", (x + 30).to_uint(), y.to_uint(), fg_r=0.5, fg_g=0.5, fg_b=0.7, bold=true)
  buffer.draw_text("Modified", (x + 40).to_uint(), y.to_uint(), fg_r=0.5, fg_g=0.5, fg_b=0.7, bold=true)
  
  // Draw files
  let visible_start = state.scroll_offset
  let visible_end = minimum(state.scroll_offset + height.to_int() - 1, state.files.length())
  
  for i = visible_start; i < visible_end; i = i + 1 {
    let file = state.files[i]
    let row = i - visible_start + 1
    let is_selected = i == state.selected_index
    
    // Draw selection highlight
    if is_selected {
      buffer.fill_rect(
        x.to_uint(), (y + row).to_uint(), width, 1_U,
        0.2, 0.3, 0.5, 1.0
      )
    }
    
    // Draw file info
    let icon = if file.is_directory { "📁" } else { get_file_icon(file.name) }
    buffer.draw_text(
      icon + " " + file.name,
      x.to_uint(), (y + row).to_uint(),
      fg_r=if is_selected { 1.0 } else { 0.8 },
      fg_g=if is_selected { 1.0 } else { 0.8 },
      fg_b=if is_selected { 1.0 } else { 0.8 }
    )
    
    // Draw size
    let size_str = if file.is_directory { "-" } else { format_file_size(file.size) }
    buffer.draw_text(
      size_str,
      (x + 30).to_uint(), (y + row).to_uint(),
      fg_r=0.6, fg_g=0.6, fg_b=0.6
    )
    
    // Draw modified time
    buffer.draw_text(
      file.modified,
      (x + 40).to_uint(), (y + row).to_uint(),
      fg_r=0.6, fg_g=0.6, fg_b=0.6
    )
  }
}

fn draw_grid_view(buffer : @ffi.Buffer, state : FileExplorerState, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  let item_width = 12
  let item_height = 4
  let columns = width.to_int() / item_width
  let rows = height.to_int() / item_height
  
  let visible_start = state.scroll_offset * columns
  let visible_end = minimum(visible_start + (rows * columns), state.files.length())
  
  for i = visible_start; i < visible_end; i = i + 1 {
    let file = state.files[i]
    let grid_index = i - visible_start
    let col = grid_index % columns
    let row = grid_index / columns
    
    let item_x = x + (col * item_width)
    let item_y = y + (row * item_height)
    
    let is_selected = i == state.selected_index
    
    // Draw selection highlight
    if is_selected {
      buffer.fill_rect(
        item_x.to_uint(), item_y.to_uint(),
        item_width.to_uint(), item_height.to_uint(),
        0.2, 0.3, 0.5, 1.0
      )
    }
    
    // Draw icon (larger in grid view)
    let icon = if file.is_directory { "📁" } else { get_file_icon(file.name) }
    buffer.draw_text(
      icon,
      (item_x + item_width / 2 - 1).to_uint(), item_y.to_uint(),
      fg_r=1.0, fg_g=1.0, fg_b=1.0
    )
    
    // Draw name (truncated)
    let name = truncate_text(file.name, item_width - 2)
    buffer.draw_text(
      name,
      (item_x + 1).to_uint(), (item_y + 2).to_uint(),
      fg_r=if is_selected { 1.0 } else { 0.8 },
      fg_g=if is_selected { 1.0 } else { 0.8 },
      fg_b=if is_selected { 1.0 } else { 0.8 }
    )
  }
}

fn draw_preview_pane(buffer : @ffi.Buffer, state : FileExplorerState, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  // Draw border
  draw_box_border(buffer, x, y, width, height, "Preview")
  
  // Draw preview content
  if state.selected_index < state.files.length() {
    let file = state.files[state.selected_index]
    
    if file.is_directory {
      // Show directory contents preview
      draw_directory_preview(buffer, file, x + 1, y + 1, width - 2_U, height - 2_U)
    } else {
      // Show file preview
      draw_file_preview(buffer, state, x + 1, y + 1, width - 2_U, height - 2_U)
    }
  }
}

fn draw_directory_preview(buffer : @ffi.Buffer, dir : FileNode, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  buffer.draw_text("📁 Directory", x.to_uint(), y.to_uint(), fg_r=0.8, fg_g=0.8, fg_b=1.0, bold=true)
  
  let mut item_count = 0
  let mut total_size = 0
  
  match dir.children {
    Some(children) => {
      item_count = children.length()
      for i = 0; i < children.length(); i = i + 1 {
        total_size = total_size + children[i].size
      }
    }
    None => ()
  }
  
  buffer.draw_text("Items: " + item_count.to_string(), x.to_uint(), (y + 2).to_uint(), fg_r=0.6, fg_g=0.6, fg_b=0.6)
  buffer.draw_text("Total size: " + format_file_size(total_size), x.to_uint(), (y + 3).to_uint(), fg_r=0.6, fg_g=0.6, fg_b=0.6)
}

fn draw_file_preview(buffer : @ffi.Buffer, state : FileExplorerState, x : Int, y : Int, width : UInt, height : UInt) -> Unit {
  if state.preview_content.length() > 0 {
    // Draw preview content (simplified - just show as text)
    let lines = split_lines(state.preview_content)
    let max_lines = minimum(lines.length(), height.to_int())
    
    for i = 0; i < max_lines; i = i + 1 {
      let line = truncate_text(lines[i], width.to_int())
      buffer.draw_text(
        line,
        x.to_uint(), (y + i).to_uint(),
        fg_r=0.7, fg_g=0.7, fg_b=0.7
      )
    }
  } else {
    buffer.draw_text("No preview available", x.to_uint(), y.to_uint(), fg_r=0.5, fg_g=0.5, fg_b=0.5)
  }
}

fn draw_status_bar(buffer : @ffi.Buffer, state : FileExplorerState, width : UInt, height : UInt) -> Unit {
  buffer.fill_rect(0_U, height - 1_U, width, 1_U, 0.1, 0.1, 0.15, 1.0)
  
  let selected_info = if state.selected_index < state.files.length() {
    let file = state.files[state.selected_index]
    file.name + " | " + format_file_size(file.size) + " | " + file.modified
  } else {
    "No selection"
  }
  
  buffer.draw_text(
    selected_info,
    2_U, height - 1_U,
    fg_r=0.7, fg_g=0.7, fg_b=0.8
  )
  
  // Draw help hint
  let help = "[h]idden [s]ort [v]iew [q]uit"
  buffer.draw_text(
    help,
    width - help.length().to_uint() - 2_U, height - 1_U,
    fg_r=0.5, fg_g=0.5, fg_b=0.6
  )
}

fn draw_vertical_divider(buffer : @ffi.Buffer, x : Int, y : Int, height : UInt) -> Unit {
  for i = 0; i < height.to_int(); i = i + 1 {
    buffer.draw_text("│", x.to_uint(), (y + i).to_uint(), fg_r=0.3, fg_g=0.3, fg_b=0.4)
  }
}

fn draw_box_border(buffer : @ffi.Buffer, x : Int, y : Int, width : UInt, height : UInt, title : String) -> Unit {
  // Top border
  buffer.draw_text("┌", x.to_uint(), y.to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
  for i = 1; i < width.to_int() - 1; i = i + 1 {
    buffer.draw_text("─", (x + i).to_uint(), y.to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
  }
  buffer.draw_text("┐", (x + width.to_int() - 1).to_uint(), y.to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
  
  // Title
  if title.length() > 0 {
    let title_with_space = " " + title + " "
    buffer.draw_text(title_with_space, (x + 2).to_uint(), y.to_uint(), fg_r=0.6, fg_g=0.6, fg_b=0.8, bold=true)
  }
  
  // Side borders
  for i = 1; i < height.to_int() - 1; i = i + 1 {
    buffer.draw_text("│", x.to_uint(), (y + i).to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
    buffer.draw_text("│", (x + width.to_int() - 1).to_uint(), (y + i).to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
  }
  
  // Bottom border
  buffer.draw_text("└", x.to_uint(), (y + height.to_int() - 1).to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
  for i = 1; i < width.to_int() - 1; i = i + 1 {
    buffer.draw_text("─", (x + i).to_uint(), (y + height.to_int() - 1).to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
  }
  buffer.draw_text("┘", (x + width.to_int() - 1).to_uint(), (y + height.to_int() - 1).to_uint(), fg_r=0.4, fg_g=0.4, fg_b=0.5)
}

// Helper functions

fn create_sample_filesystem() -> FixedArray[FileNode] {
  let files = FixedArray::make(8, FileNode::{ name: "", path: "", is_directory: false, expanded: false, children: None, size: 0, modified: "" })
  
  // Create sample directory structure
  files[0] = FileNode::{
    name: "src",
    path: "/home/user/src",
    is_directory: true,
    expanded: false,
    children: Some(create_src_children()),
    size: 0,
    modified: "2024-01-15"
  }
  
  files[1] = FileNode::{
    name: "docs",
    path: "/home/user/docs",
    is_directory: true,
    expanded: false,
    children: Some(create_docs_children()),
    size: 0,
    modified: "2024-01-14"
  }
  
  files[2] = FileNode::{
    name: "README.md",
    path: "/home/user/README.md",
    is_directory: false,
    expanded: false,
    children: None,
    size: 2048,
    modified: "2024-01-13"
  }
  
  files[3] = FileNode::{
    name: "package.json",
    path: "/home/user/package.json",
    is_directory: false,
    expanded: false,
    children: None,
    size: 512,
    modified: "2024-01-12"
  }
  
  files[4] = FileNode::{
    name: "build.sh",
    path: "/home/user/build.sh",
    is_directory: false,
    expanded: false,
    children: None,
    size: 256,
    modified: "2024-01-11"
  }
  
  files[5] = FileNode::{
    name: "tests",
    path: "/home/user/tests",
    is_directory: true,
    expanded: false,
    children: None,
    size: 0,
    modified: "2024-01-10"
  }
  
  files[6] = FileNode::{
    name: ".gitignore",
    path: "/home/user/.gitignore",
    is_directory: false,
    expanded: false,
    children: None,
    size: 128,
    modified: "2024-01-09"
  }
  
  files[7] = FileNode::{
    name: "LICENSE",
    path: "/home/user/LICENSE",
    is_directory: false,
    expanded: false,
    children: None,
    size: 1024,
    modified: "2024-01-08"
  }
  
  files
}

fn create_src_children() -> FixedArray[FileNode] {
  let children = FixedArray::make(4, FileNode::{ name: "", path: "", is_directory: false, expanded: false, children: None, size: 0, modified: "" })
  
  children[0] = FileNode::{
    name: "main.mbt",
    path: "/home/user/src/main.mbt",
    is_directory: false,
    expanded: false,
    children: None,
    size: 4096,
    modified: "2024-01-15"
  }
  
  children[1] = FileNode::{
    name: "utils.mbt",
    path: "/home/user/src/utils.mbt",
    is_directory: false,
    expanded: false,
    children: None,
    size: 2048,
    modified: "2024-01-14"
  }
  
  children[2] = FileNode::{
    name: "types.mbt",
    path: "/home/user/src/types.mbt",
    is_directory: false,
    expanded: false,
    children: None,
    size: 1024,
    modified: "2024-01-13"
  }
  
  children[3] = FileNode::{
    name: "components",
    path: "/home/user/src/components",
    is_directory: true,
    expanded: false,
    children: None,
    size: 0,
    modified: "2024-01-12"
  }
  
  children
}

fn create_docs_children() -> FixedArray[FileNode] {
  let children = FixedArray::make(3, FileNode::{ name: "", path: "", is_directory: false, expanded: false, children: None, size: 0, modified: "" })
  
  children[0] = FileNode::{
    name: "api.md",
    path: "/home/user/docs/api.md",
    is_directory: false,
    expanded: false,
    children: None,
    size: 8192,
    modified: "2024-01-14"
  }
  
  children[1] = FileNode::{
    name: "guide.md",
    path: "/home/user/docs/guide.md",
    is_directory: false,
    expanded: false,
    children: None,
    size: 4096,
    modified: "2024-01-13"
  }
  
  children[2] = FileNode::{
    name: "examples",
    path: "/home/user/docs/examples",
    is_directory: true,
    expanded: false,
    children: None,
    size: 0,
    modified: "2024-01-12"
  }
  
  children
}

fn get_file_icon(filename : String) -> String {
  // Determine icon based on file extension
  if filename.strip_suffix(".mbt").is_some() { "🔷" }
  else if filename.strip_suffix(".md").is_some() { "📝" }
  else if filename.strip_suffix(".json").is_some() { "📋" }
  else if filename.strip_suffix(".sh").is_some() { "🔧" }
  else if filename.strip_suffix(".txt").is_some() { "📄" }
  else if filename.strip_suffix(".png").is_some() || filename.strip_suffix(".jpg").is_some() { "🖼️" }
  else if filename.strip_suffix(".mp3").is_some() || filename.strip_suffix(".wav").is_some() { "🎵" }
  else if filename.strip_suffix(".mp4").is_some() || filename.strip_suffix(".avi").is_some() { "🎬" }
  else if filename.strip_suffix(".zip").is_some() || filename.strip_suffix(".tar").is_some() { "📦" }
  else { "📄" }
}

fn format_file_size(size : Int) -> String {
  if size < 1024 {
    size.to_string() + "B"
  } else if size < 1024 * 1024 {
    (size / 1024).to_string() + "KB"
  } else {
    (size / (1024 * 1024)).to_string() + "MB"
  }
}

fn truncate_text(text : String, max_width : Int) -> String {
  if text.length() <= max_width {
    text
  } else {
    let mut result = ""
    for i = 0; i < max_width - 3; i = i + 1 {
      result = result + text[i].to_string()
    }
    result + "..."
  }
}

fn split_lines(text : String) -> FixedArray[String] {
  // Simplified line splitting (in real implementation would handle newlines properly)
  let lines = FixedArray::make(1, "")
  lines[0] = text
  lines
}

fn update_scroll(state : FileExplorerState) -> Unit {
  // Update scroll offset to keep selected item visible
  let viewport_height = 20  // Approximate viewport height
  
  if state.selected_index < state.scroll_offset {
    state.scroll_offset = state.selected_index
  } else if state.selected_index >= state.scroll_offset + viewport_height {
    state.scroll_offset = state.selected_index - viewport_height + 1
  }
}

fn update_preview(state : FileExplorerState) -> Unit {
  if state.selected_index < state.files.length() {
    let file = state.files[state.selected_index]
    if not(file.is_directory) {
      // Generate sample preview content based on file type
      if file.name.strip_suffix(".mbt").is_some() {
        state.preview_content = "pub fn main() -> Unit {\n  println(\"Hello, MoonBit!\")\n}\n\n// Sample code preview..."
      } else if file.name.strip_suffix(".md").is_some() {
        state.preview_content = "# Documentation\n\nThis is a sample markdown preview.\n\n## Features\n- Feature 1\n- Feature 2"
      } else if file.name.strip_suffix(".json").is_some() {
        state.preview_content = "{\n  \"name\": \"sample\",\n  \"version\": \"1.0.0\",\n  \"description\": \"Sample JSON file\"\n}"
      } else {
        state.preview_content = "Binary file or unsupported format"
      }
    } else {
      state.preview_content = ""
    }
  }
}

fn navigate_to(state : FileExplorerState, path : String) -> Unit {
  state.current_path = path
  state.selected_index = 0
  state.scroll_offset = 0
  refresh_files(state)
}

fn navigate_to_parent(state : FileExplorerState) -> Unit {
  // Find last slash and navigate to parent
  let mut last_slash = -1
  for i = 0; i < state.current_path.length(); i = i + 1 {
    if state.current_path[i] == '/' {
      last_slash = i
    }
  }
  
  if last_slash > 0 {
    let mut parent = ""
    for i = 0; i < last_slash; i = i + 1 {
      parent = parent + state.current_path[i].to_string()
    }
    navigate_to(state, parent)
  }
}

fn refresh_files(state : FileExplorerState) -> Unit {
  // Filter files based on show_hidden setting
  // In real implementation, would reload from filesystem
  sort_files(state)
}

fn sort_files(state : FileExplorerState) -> Unit {
  // Sort files based on current sort mode
  // Simplified - in real implementation would properly sort the array
}

fn handle_mouse_click(state : FileExplorerState, x : Int, y : Int) -> Unit {
  // Calculate which file was clicked based on coordinates
  // Simplified implementation
  let file_index = (y - 3) + state.scroll_offset
  if file_index >= 0 && file_index < state.files.length() {
    state.selected_index = file_index
    update_preview(state)
  }
}

fn view_mode_string(mode : ViewMode) -> String {
  match mode {
    ViewMode::List => "List"
    ViewMode::Tree => "Tree"
    ViewMode::Grid => "Grid"
  }
}

fn sort_mode_string(mode : SortMode) -> String {
  match mode {
    SortMode::Name => "Name"
    SortMode::Size => "Size"
    SortMode::Modified => "Modified"
    SortMode::Type => "Type"
  }
}

fn minimum(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}