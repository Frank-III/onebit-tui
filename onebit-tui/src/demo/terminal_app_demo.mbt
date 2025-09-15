// OneBit-TUI Terminal App Demo
// A real terminal application showcasing actual capabilities

pub fn run_terminal_app() -> Unit {
  // Initialize terminal
  let (width, height) = @ffi.get_terminal_size()
  
  match @ffi.Renderer::new(width, height) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      match @ffi.TerminalSession::new(raw_mode=true, mouse=true, resize_detection=true) {
        None => {
          println("Failed to setup terminal")
          renderer.destroy()
          return
        }
        Some(session) => {
          // Application state
          let mut current_view = "file_browser"  // file_browser, editor, terminal
          let mut selected_file = 0
          let mut editor_content = ""
          let mut cursor_x = 0
          let mut cursor_y = 0
          let command_history : Array[String] = []
          let mut command_input = ""
          let mut status_message = "Ready"
          
          // Mock file system
          let files = [
            ("src/", "folder", 0),
            ("main.mbt", "file", 1024),
            ("moon.mod.json", "file", 256),
            ("README.md", "file", 4096),
            ("lib/", "folder", 0),
            ("build.sh", "file", 512),
            (".gitignore", "file", 128)
          ]
          
          // Main loop
          let mut running = true
          while running {
            let buffer = renderer.get_next_buffer()
            buffer.clear(0.02, 0.02, 0.05, 1.0)
            
            // Draw title bar
            buffer.fill_rect(0_U, 0_U, width, 1_U, 0.1, 0.1, 0.2, 1.0)
            buffer.draw_text("🌙 OneBit Terminal", 1_U, 0_U, 
              fg_r=0.4, fg_g=0.8, fg_b=1.0, bold=true)
            buffer.draw_text("[\{current_view}]", (width - 20_U), 0_U,
              fg_r=0.5, fg_g=0.5, fg_b=0.6)
            
            // Draw main content area based on view
            match current_view {
              "file_browser" => {
                draw_file_browser(buffer, files, selected_file, width, height)
              }
              "editor" => {
                draw_editor(buffer, editor_content, cursor_x, cursor_y, width, height)
              }
              "terminal" => {
                draw_terminal(buffer, command_history, command_input, width, height)
              }
              _ => ()
            }
            
            // Draw status bar
            let status_y = height - 1_U
            buffer.fill_rect(0_U, status_y, width, 1_U, 0.08, 0.08, 0.12, 1.0)
            buffer.draw_text(status_message, 1_U, status_y, 
              fg_r=0.6, fg_g=0.6, fg_b=0.7)
            buffer.draw_text("[F1] Files  [F2] Editor  [F3] Terminal  [q] Quit", 
              (width / 2_U - 20_U), status_y,
              fg_r=0.4, fg_g=0.4, fg_b=0.5)
            
            // Render
            renderer.render()
            
            // Handle input
            match @ffi.poll_input_event() {
              @ffi.InputEvent::Key(key) => {
                match key {
                  @ffi.KeyEvent::Char(113) | @ffi.KeyEvent::Escape => { // 'q' or ESC
                    running = false
                  }
                  @ffi.KeyEvent::F(1) => {
                    current_view = "file_browser"
                    status_message = "File Browser"
                  }
                  @ffi.KeyEvent::F(2) => {
                    current_view = "editor"
                    status_message = "Text Editor"
                  }
                  @ffi.KeyEvent::F(3) => {
                    current_view = "terminal"
                    status_message = "Terminal"
                  }
                  @ffi.KeyEvent::ArrowUp => {
                    match current_view {
                      "file_browser" => {
                        if selected_file > 0 { 
                          selected_file = selected_file - 1 
                        }
                      }
                      "editor" => {
                        if cursor_y > 0 { cursor_y = cursor_y - 1 }
                      }
                      _ => ()
                    }
                  }
                  @ffi.KeyEvent::ArrowDown => {
                    match current_view {
                      "file_browser" => {
                        if selected_file < files.length() - 1 { 
                          selected_file = selected_file + 1 
                        }
                      }
                      "editor" => {
                        cursor_y = cursor_y + 1
                      }
                      _ => ()
                    }
                  }
                  @ffi.KeyEvent::ArrowLeft => {
                    if current_view == "editor" && cursor_x > 0 {
                      cursor_x = cursor_x - 1
                    }
                  }
                  @ffi.KeyEvent::ArrowRight => {
                    if current_view == "editor" {
                      cursor_x = cursor_x + 1
                    }
                  }
                  @ffi.KeyEvent::Enter => {
                    match current_view {
                      "file_browser" => {
                        let (name, type_, _) = files[selected_file]
                        if type_ == "file" {
                          current_view = "editor"
                          editor_content = "// Editing: \{name}\n\n"
                          status_message = "Opened \{name}"
                        }
                      }
                      "terminal" => {
                        if command_input != "" {
                          command_history.push("> " + command_input)
                          command_history.push("Command executed: " + command_input)
                          command_input = ""
                        }
                      }
                      _ => ()
                    }
                  }
                  @ffi.KeyEvent::Char(c) if c >= 32 && c < 127 => {
                    match current_view {
                      "editor" => {
                        editor_content = editor_content + c.unsafe_to_char().to_string()
                      }
                      "terminal" => {
                        command_input = command_input + c.unsafe_to_char().to_string()
                      }
                      _ => ()
                    }
                  }
                  @ffi.KeyEvent::Backspace => {
                    match current_view {
                      "editor" => {
                        if editor_content.length() > 0 {
                          editor_content = editor_content.substring(end=editor_content.length() - 1)
                        }
                      }
                      "terminal" => {
                        if command_input.length() > 0 {
                          command_input = command_input.substring(end=command_input.length() - 1)
                        }
                      }
                      _ => ()
                    }
                  }
                  _ => ()
                }
              }
              @ffi.InputEvent::MouseDown(x, y, _) => {
                // Click on status bar shortcuts
                if y == (height - 1).reinterpret_as_int() {
                  if x < 10 { current_view = "file_browser" }
                  else if x < 20 { current_view = "editor" }
                  else if x < 30 { current_view = "terminal" }
                }
                // Click on files
                if current_view == "file_browser" && y > 2 && y < (height - 2).reinterpret_as_int() {
                  let clicked = (y - 3)
                  if clicked >= 0 && clicked < files.length() {
                    selected_file = clicked
                  }
                }
              }
              @ffi.InputEvent::Resize(new_width, new_height) => {
                renderer.resize(new_width, new_height)
                status_message = "Resized to \{new_width}x\{new_height}"
              }
              _ => {
                @ffi.sleep_ms(16) // ~60 FPS
              }
            }
          }
          
          // Cleanup
          session.cleanup()
          renderer.destroy()
          println("\nGoodbye from OneBit Terminal!")
        }
      }
    }
  }
}

fn draw_file_browser(
  buffer : @ffi.Buffer, 
  files : Array[(String, String, Int)], 
  selected : Int,
  width : UInt,
  height : UInt
) -> Unit {
  // Title
  buffer.draw_text("📁 File Browser", 2_U, 2_U, 
    fg_r=0.8, fg_g=0.8, fg_b=0.9, bold=true)
  
  // File list
  for i = 0; i < files.length(); i = i + 1 {
    let (name, type_, size) = files[i]
    let y = (3 + i).reinterpret_as_uint()
    
    // Highlight selected
    if i == selected {
      buffer.fill_rect(1_U, y, width - 2_U, 1_U, 0.1, 0.15, 0.25, 1.0)
    }
    
    // Icon and name
    let icon = if type_ == "folder" { "📁" } else { "📄" }
    buffer.draw_text(icon + " " + name, 3_U, y,
      fg_r=if i == selected { 1.0 } else { 0.7 },
      fg_g=if i == selected { 1.0 } else { 0.7 },
      fg_b=if i == selected { 0.6 } else { 0.7 })
    
    // Size for files
    if type_ == "file" {
      let size_str = if size > 1024 { 
        "\{size / 1024} KB" 
      } else { 
        "\{size} B" 
      }
      buffer.draw_text(size_str, width - 15_U, y,
        fg_r=0.5, fg_g=0.5, fg_b=0.6)
    }
  }
}

fn draw_editor(
  buffer : @ffi.Buffer,
  content : String,
  cursor_x : Int,
  cursor_y : Int,
  width : UInt,
  height : UInt
) -> Unit {
  // Title with file info
  buffer.draw_text("✏️ Text Editor", 2_U, 2_U,
    fg_r=0.8, fg_g=0.8, fg_b=0.9, bold=true)
  buffer.draw_text("Ln \{cursor_y + 1}, Col \{cursor_x + 1}", 
    width - 20_U, 2_U,
    fg_r=0.5, fg_g=0.5, fg_b=0.6)
  
  // Line numbers and content
  let lines = if content == "" { [""] } else { split_lines(content) }
  for i = 0; i < lines.length() && i < (height - 5).reinterpret_as_int(); i = i + 1 {
    let y = (4 + i).reinterpret_as_uint()
    
    // Line number
    buffer.draw_text("\{i + 1}", 2_U, y,
      fg_r=0.3, fg_g=0.3, fg_b=0.4)
    
    // Content
    buffer.draw_text(lines[i], 6_U, y,
      fg_r=0.9, fg_g=0.9, fg_b=0.9)
  }
  
  // Draw cursor
  let cursor_screen_x = 6_U + cursor_x.reinterpret_as_uint()
  let cursor_screen_y = 4_U + cursor_y.reinterpret_as_uint()
  buffer.fill_rect(cursor_screen_x, cursor_screen_y, 1_U, 1_U,
    0.8, 0.8, 0.2, 0.8)
}

fn draw_terminal(
  buffer : @ffi.Buffer,
  history : Array[String],
  input : String,
  width : UInt,
  height : UInt
) -> Unit {
  // Title
  buffer.draw_text("💻 Terminal", 2_U, 2_U,
    fg_r=0.8, fg_g=0.8, fg_b=0.9, bold=true)
  
  // History
  let start = if history.length() > 15 { 
    history.length() - 15 
  } else { 
    0 
  }
  
  for i = start; i < history.length(); i = i + 1 {
    let y = (4 + (i - start)).reinterpret_as_uint()
    let line = history[i]
    let is_command = line.starts_with(">")
    
    buffer.draw_text(line, 2_U, y,
      fg_r=if is_command { 0.4 } else { 0.8 },
      fg_g=if is_command { 0.8 } else { 0.8 },
      fg_b=if is_command { 0.4 } else { 0.8 })
  }
  
  // Input line
  let input_y = height - 3_U
  buffer.draw_text("> " + input, 2_U, input_y,
    fg_r=0.4, fg_g=0.9, fg_b=0.4)
  
  // Cursor
  buffer.fill_rect((4 + input.length()).reinterpret_as_uint(), input_y, 
    1_U, 1_U, 0.9, 0.9, 0.9, 0.8)
}

// Helper function to split string into lines
fn split_lines(s : String) -> Array[String] {
  let lines : Array[String] = []
  let mut current = ""
  
  for i = 0; i < s.length(); i = i + 1 {
    let char = s[i]
    if char == '\n' {
      lines.push(current)
      current = ""
    } else {
      current = current + char.to_string()
    }
  }
  
  if current != "" || s.ends_with("\n") {
    lines.push(current)
  }
  
  if lines.is_empty() { [""] } else { lines }
}