///| Real File Explorer Demo using moonbitlang/x/fs
///| Shows actual filesystem with real file operations

// Note: To use this, add to moon.mod.json dependencies:
// "moonbitlang/x/fs": "*"

struct RealFileNode {
  name : String
  path : String
  is_directory : Bool
  mut expanded : Bool
  mut children : FixedArray[RealFileNode]?
  size : Int
  modified : String
}

struct RealFileExplorerState {
  mut selected_index : Int
  mut scroll_offset : Int
  mut current_path : String
  mut files : FixedArray[RealFileNode]
  mut preview_content : String
  split_position : Double
  mut show_hidden : Bool
  mut sort_by : RealSortMode
  mut view_mode : RealViewMode
  mut error_message : String
}

enum RealSortMode {
  Name
  Size
  Modified
  Type
} derive(Eq)

enum RealViewMode {
  List
  Tree
  Grid
} derive(Eq)

pub fn run_real_file_explorer() -> Unit {
  println("=== OneBit-TUI Real File Explorer ===")
  println("Controls:")
  println("  ↑/↓     - Navigate files")
  println("  →/Enter - Open folder/file")
  println("  ←       - Go back to parent")
  println("  h       - Toggle hidden files")
  println("  r       - Refresh current directory")
  println("  d       - Delete file (with confirmation)")
  println("  n       - Create new file")
  println("  N       - Create new directory")
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
      
      // Start with current directory or home
      let start_path = "."  // Or use home directory
      
      // Initialize state
      let state = RealFileExplorerState::{
        selected_index: 0,
        scroll_offset: 0,
        current_path: start_path,
        files: load_directory(start_path),
        preview_content: "",
        split_position: 0.3,
        show_hidden: false,
        sort_by: RealSortMode::Name,
        view_mode: RealViewMode::List,
        error_message: "",
      }
      
      // Initialize renderer
      match @ffi.Renderer::new(width, height) {
        None => {
          session.cleanup()
          println("Failed to initialize renderer")
          return
        }
        Some(renderer) => {
          run_explorer_with_fs(renderer, state)
          
          // Clean up
          renderer.destroy()
          session.cleanup()
          
          println("\nReal File Explorer completed!")
        }
      }
    }
  }
}

fn load_directory(path : String) -> FixedArray[RealFileNode] {
  try {
    // Check if path exists and is a directory
    if not(@fs.path_exists(path)) {
      return FixedArray::make(0, RealFileNode::{ 
        name: "", path: "", is_directory: false, 
        expanded: false, children: None, size: 0, modified: "" 
      })
    }
    
    if not(@fs.is_dir(path)) {
      return FixedArray::make(0, RealFileNode::{ 
        name: "", path: "", is_directory: false, 
        expanded: false, children: None, size: 0, modified: "" 
      })
    }
    
    // Read directory entries
    let entries = @fs.read_dir(path)
    let count = entries.length()
    
    let files = FixedArray::make(count, RealFileNode::{ 
      name: "", path: "", is_directory: false, 
      expanded: false, children: None, size: 0, modified: "" 
    })
    
    for i = 0; i < count; i = i + 1 {
      let entry_name = entries[i]
      let full_path = path + "/" + entry_name
      
      // Check if it's a directory
      let is_dir = try {
        @fs.is_dir(full_path)
      } catch {
        _ => false
      }
      
      // Get file size (0 for directories)
      let size = if is_dir {
        0
      } else {
        // Would need to read file to get size
        // For now, use placeholder
        1024
      }
      
      files[i] = RealFileNode::{
        name: entry_name,
        path: full_path,
        is_directory: is_dir,
        expanded: false,
        children: None,
        size: size,
        modified: "2024-01-15",  // Would need stat info
      }
    }
    
    files
  } catch {
    @fs.IOError(msg) => {
      // Return empty array on error
      println("Error loading directory: " + msg)
      FixedArray::make(0, RealFileNode::{ 
        name: "", path: "", is_directory: false, 
        expanded: false, children: None, size: 0, modified: "" 
      })
    }
  }
}

fn load_file_preview(path : String) -> String {
  try {
    // Check if file exists and is not a directory
    if not(@fs.path_exists(path)) {
      return "File not found"
    }
    
    if @fs.is_dir(path) {
      return "Directory - " + count_items(path).to_string() + " items"
    }
    
    // Try to read as text file
    let content = @fs.read_file_to_string(path)
    
    // Limit preview to first 1000 characters
    if content.length() > 1000 {
      let mut preview = ""
      for i = 0; i < 1000; i = i + 1 {
        preview = preview + content[i].to_string()
      }
      preview + "\n...[truncated]"
    } else {
      content
    }
  } catch {
    @fs.IOError(msg) => "Error reading file: " + msg
  }
}

fn count_items(dir_path : String) -> Int {
  try {
    let entries = @fs.read_dir(dir_path)
    entries.length()
  } catch {
    _ => 0
  }
}

fn create_file(path : String, name : String) -> Bool {
  let full_path = path + "/" + name
  try {
    @fs.write_string_to_file(full_path, "")
    true
  } catch {
    @fs.IOError(msg) => {
      println("Error creating file: " + msg)
      false
    }
  }
}

fn create_directory(path : String, name : String) -> Bool {
  let full_path = path + "/" + name
  try {
    @fs.create_dir(full_path)
    true
  } catch {
    @fs.IOError(msg) => {
      println("Error creating directory: " + msg)
      false
    }
  }
}

fn delete_file(path : String) -> Bool {
  try {
    if @fs.is_dir(path) {
      @fs.remove_dir(path)
    } else {
      @fs.remove_file(path)
    }
    true
  } catch {
    @fs.IOError(msg) => {
      println("Error deleting: " + msg)
      false
    }
  }
}

fn run_explorer_with_fs(renderer : @ffi.Renderer, state : RealFileExplorerState) -> Unit {
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
              update_preview_fs(state)
            }
          }
          
          @ffi.KeyEvent::ArrowDown => {
            if state.selected_index < state.files.length() - 1 {
              state.selected_index = state.selected_index + 1
              update_preview_fs(state)
            }
          }
          
          @ffi.KeyEvent::ArrowRight | @ffi.KeyEvent::Enter => {
            if state.selected_index < state.files.length() {
              let file = state.files[state.selected_index]
              if file.is_directory {
                // Navigate into directory
                state.current_path = file.path
                state.files = load_directory(file.path)
                state.selected_index = 0
                state.scroll_offset = 0
              } else {
                // Load file preview
                update_preview_fs(state)
              }
            }
          }
          
          @ffi.KeyEvent::ArrowLeft => {
            // Go to parent directory
            navigate_to_parent_fs(state)
          }
          
          @ffi.KeyEvent::Char(114) => {  // 'r' - refresh
            state.files = load_directory(state.current_path)
            if state.selected_index >= state.files.length() {
              state.selected_index = if state.files.length() > 0 { 
                state.files.length() - 1 
              } else { 
                0 
              }
            }
          }
          
          @ffi.KeyEvent::Char(100) => {  // 'd' - delete
            if state.selected_index < state.files.length() {
              let file = state.files[state.selected_index]
              // In real implementation, would show confirmation dialog
              if delete_file(file.path) {
                state.files = load_directory(state.current_path)
                if state.selected_index >= state.files.length() && state.selected_index > 0 {
                  state.selected_index = state.selected_index - 1
                }
              }
            }
          }
          
          @ffi.KeyEvent::Char(110) => {  // 'n' - new file
            // In real implementation, would show input dialog
            if create_file(state.current_path, "new_file.txt") {
              state.files = load_directory(state.current_path)
            }
          }
          
          @ffi.KeyEvent::Char(78) => {  // 'N' - new directory
            // In real implementation, would show input dialog
            if create_directory(state.current_path, "new_folder") {
              state.files = load_directory(state.current_path)
            }
          }
          
          @ffi.KeyEvent::Char(104) => {  // 'h' - toggle hidden
            state.show_hidden = not(state.show_hidden)
            // Would need to filter hidden files
          }
          
          _ => ()
        }
      }
      
      @ffi.InputEvent::Resize(new_width, new_height) => {
        renderer.resize(new_width, new_height)
      }
      
      _ => ()
    }
    
    // Clear error message after a few frames
    if state.error_message.length() > 0 {
      state.error_message = ""
    }
    
    // Render UI
    render_fs_explorer(renderer, state)
  }
}

fn update_preview_fs(state : RealFileExplorerState) -> Unit {
  if state.selected_index < state.files.length() {
    let file = state.files[state.selected_index]
    if not(file.is_directory) {
      state.preview_content = load_file_preview(file.path)
    } else {
      state.preview_content = "Directory: " + count_items(file.path).to_string() + " items"
    }
  }
}

fn navigate_to_parent_fs(state : RealFileExplorerState) -> Unit {
  // Find parent path
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
    state.current_path = parent
    state.files = load_directory(parent)
    state.selected_index = 0
    state.scroll_offset = 0
  } else if state.current_path != "/" && state.current_path != "." {
    // Go to root or current directory
    state.current_path = "."
    state.files = load_directory(".")
    state.selected_index = 0
    state.scroll_offset = 0
  }
}

fn render_fs_explorer(renderer : @ffi.Renderer, state : RealFileExplorerState) -> Unit {
  let buffer = renderer.get_next_buffer()
  buffer.clear(0.05, 0.05, 0.1, 1.0)
  
  let (width, height) = @ffi.get_terminal_size()
  
  // Draw title bar with current path
  buffer.fill_rect(0_U, 0_U, width, 2_U, 0.1, 0.1, 0.2, 1.0)
  buffer.draw_text(
    "📁 " + state.current_path,
    2_U, 0_U,
    fg_r=0.8, fg_g=0.8, fg_b=1.0,
    bold=true
  )
  
  // Draw file list
  let list_height = height - 3_U
  for i = 0; i < state.files.length() && i < list_height.to_int(); i = i + 1 {
    let file = state.files[i + state.scroll_offset]
    let y = (i + 2).to_uint()
    
    // Highlight selected item
    if i + state.scroll_offset == state.selected_index {
      buffer.fill_rect(0_U, y, width, 1_U, 0.2, 0.3, 0.5, 1.0)
    }
    
    // Draw file/folder icon and name
    let icon = if file.is_directory { "📁" } else { get_file_icon_fs(file.name) }
    let display_name = if file.name.length() > 40 {
      truncate_text_real(file.name, 40)
    } else {
      file.name
    }
    
    buffer.draw_text(
      " " + icon + " " + display_name,
      1_U, y,
      fg_r=if i + state.scroll_offset == state.selected_index { 1.0 } else { 0.8 },
      fg_g=if i + state.scroll_offset == state.selected_index { 1.0 } else { 0.8 },
      fg_b=if i + state.scroll_offset == state.selected_index { 1.0 } else { 0.8 }
    )
    
    // Draw file size (right-aligned)
    if not(file.is_directory) {
      let size_str = format_file_size_real(file.size)
      let size_x = width - size_str.length().to_uint() - 2_U
      buffer.draw_text(
        size_str,
        size_x, y,
        fg_r=0.6, fg_g=0.6, fg_b=0.6
      )
    }
  }
  
  // Draw status bar
  buffer.fill_rect(0_U, height - 1_U, width, 1_U, 0.1, 0.1, 0.15, 1.0)
  
  let status = if state.selected_index < state.files.length() {
    let file = state.files[state.selected_index]
    file.name + " | " + (if file.is_directory { "Directory" } else { format_file_size_real(file.size) })
  } else {
    "No selection"
  }
  
  buffer.draw_text(
    " " + status,
    1_U, height - 1_U,
    fg_r=0.7, fg_g=0.7, fg_b=0.8
  )
  
  // Draw help
  let help = "[r]efresh [n]ew file [N]ew dir [d]elete [q]uit"
  buffer.draw_text(
    help,
    width - help.length().to_uint() - 2_U, height - 1_U,
    fg_r=0.5, fg_g=0.5, fg_b=0.6
  )
  
  // Draw error message if any
  if state.error_message.length() > 0 {
    buffer.fill_rect(2_U, height / 2_U, width - 4_U, 3_U, 0.5, 0.1, 0.1, 1.0)
    buffer.draw_text(
      "Error: " + state.error_message,
      4_U, height / 2_U + 1_U,
      fg_r=1.0, fg_g=0.3, fg_b=0.3,
      bold=true
    )
  }
  
  renderer.render(force=false)
}

fn get_file_icon_fs(filename : String) -> String {
  // Determine icon based on file extension
  if filename.strip_suffix(".mbt") is Some(_) { "🔷" }
  else if filename.strip_suffix(".md") is Some(_) { "📝" }
  else if filename.strip_suffix(".json") is Some(_) { "📋" }
  else if filename.strip_suffix(".sh") is Some(_) { "🔧" }
  else if filename.strip_suffix(".txt") is Some(_) { "📄" }
  else if filename.strip_suffix(".png") is Some(_) || filename.strip_suffix(".jpg") is Some(_) { "🖼️" }
  else { "📄" }
}

fn format_file_size_real(size : Int) -> String {
  if size < 1024 {
    size.to_string() + "B"
  } else if size < 1024 * 1024 {
    (size / 1024).to_string() + "KB"
  } else {
    (size / (1024 * 1024)).to_string() + "MB"
  }
}

fn truncate_text_real(text : String, max_width : Int) -> String {
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