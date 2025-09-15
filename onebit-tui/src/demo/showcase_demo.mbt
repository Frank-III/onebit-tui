// OneBit-TUI Showcase Demo
// Demonstrates components, layouts, and interactive features

///|
pub fn run_showcase_demo() -> Unit {
  // Get terminal size
  let (width, height) = @ffi.get_terminal_size()

  // Create renderer
  match @ffi.Renderer::new(width, height) {
    None => {
      println("Failed to create renderer")
      return
    }
    Some(renderer) => {
      // Set dark theme background
      renderer.set_background_color(0.05, 0.05, 0.1, 1.0)

      // Create terminal session for input
      match
        @ffi.TerminalSession::new(
          raw_mode=true,
          mouse=true,
          resize_detection=true,
        ) {
        None => {
          println("Failed to setup terminal")
          renderer.destroy()
          return
        }
        Some(session) => {
          // Application state
          let mut current_tab = 0
          let mut selected_item = 0
          let mut progress = 0.0
          let mut text_input = ""
          let mut show_modal = false

          // Tab names
          let tabs = ["Dashboard", "Components", "Layout", "About"]

          // List items for demo
          let list_items = [
            "🚀 High Performance Rendering", "📦 Component Library", "🎨 Theme Support",
            "⚡ Event System", "🔧 FFI Integration", "📐 Yoga Layout",
          ]

          // Main render loop
          let mut running = true
          while running {
            let buffer = renderer.get_next_buffer()
            buffer.clear(0.05, 0.05, 0.1, 1.0)

            // Draw header
            buffer.fill_rect(0_U, 0_U, width, 3_U, 0.1, 0.1, 0.2, 1.0)
            buffer.draw_text(
              "⚡ OneBit-TUI Showcase",
              2_U,
              1_U,
              fg_r=0.4,
              fg_g=0.8,
              fg_b=1.0,
              bold=true,
            )
            buffer.draw_text(
              "Built with MoonBit + FFI",
              width - 25_U,
              1_U,
              fg_r=0.6,
              fg_g=0.6,
              fg_b=0.7,
            )

            // Draw tabs
            let mut tab_x = 2_U
            for i = 0; i < tabs.length(); i = i + 1 {
              let tab = tabs[i]
              let is_active = i == current_tab
              if is_active {
                buffer.fill_rect(
                  tab_x,
                  3_U,
                  (tab.length() + 4).reinterpret_as_uint(),
                  3_U,
                  0.15,
                  0.15,
                  0.25,
                  1.0,
                )
              }
              buffer.draw_text(
                tab,
                tab_x + 2_U,
                4_U,
                fg_r=if is_active { 1.0 } else { 0.6 },
                fg_g=if is_active { 1.0 } else { 0.6 },
                fg_b=if is_active { 1.0 } else { 0.6 },
                bold=is_active,
              )
              tab_x = tab_x + (tab.length() + 5).reinterpret_as_uint()
            }

            // Draw content based on current tab
            match current_tab {
              0 => { // Dashboard
                // Stats panel
                buffer.fill_rect(2_U, 7_U, 40_U, 10_U, 0.08, 0.08, 0.12, 1.0)
                buffer.draw_text(
                  "📊 Statistics",
                  4_U,
                  8_U,
                  fg_r=0.8,
                  fg_g=0.8,
                  fg_b=0.9,
                  bold=true,
                )
                buffer.draw_text("Terminal: \{width}x\{height}", 4_U, 10_U)
                buffer.draw_text("Components: 6 loaded", 4_U, 11_U)
                buffer.draw_text("FPS: 60", 4_U, 12_U)
                buffer.draw_text("Memory: 2.4 MB", 4_U, 13_U)

                // Progress bar
                buffer.draw_text("Progress:", 4_U, 15_U)
                let progress_width = 30_U
                buffer.fill_rect(
                  14_U, 15_U, progress_width, 1_U, 0.2, 0.2, 0.3, 1.0,
                )
                let filled = (progress * progress_width.to_double())
                  .to_int()
                  .reinterpret_as_uint()
                buffer.fill_rect(14_U, 15_U, filled, 1_U, 0.2, 0.8, 0.4, 1.0)

                // Component list
                buffer.fill_rect(45_U, 7_U, 40_U, 15_U, 0.08, 0.08, 0.12, 1.0)
                buffer.draw_text(
                  "📦 Components",
                  47_U,
                  8_U,
                  fg_r=0.8,
                  fg_g=0.8,
                  fg_b=0.9,
                  bold=true,
                )
                for i = 0; i < list_items.length(); i = i + 1 {
                  let is_selected = i == selected_item
                  if is_selected {
                    buffer.fill_rect(
                      47_U,
                      (10 + i).reinterpret_as_uint(),
                      36_U,
                      1_U,
                      0.2,
                      0.3,
                      0.5,
                      1.0,
                    )
                  }
                  buffer.draw_text(
                    list_items[i],
                    48_U,
                    (10 + i).reinterpret_as_uint(),
                    fg_r=if is_selected { 1.0 } else { 0.7 },
                    fg_g=if is_selected { 1.0 } else { 0.7 },
                    fg_b=if is_selected { 0.5 } else { 0.7 },
                  )
                }
              }
              1 => { // Components
                buffer.draw_text(
                  "🧩 Component Gallery",
                  4_U,
                  8_U,
                  fg_r=0.8,
                  fg_g=0.8,
                  fg_b=0.9,
                  bold=true,
                )

                // Button examples
                buffer.fill_rect(4_U, 11_U, 15_U, 3_U, 0.2, 0.4, 0.8, 1.0)
                buffer.draw_text(
                  "Primary",
                  8_U,
                  12_U,
                  fg_r=1.0,
                  fg_g=1.0,
                  fg_b=1.0,
                )
                buffer.fill_rect(22_U, 11_U, 15_U, 3_U, 0.15, 0.15, 0.2, 1.0)
                buffer.draw_text(
                  "Secondary",
                  25_U,
                  12_U,
                  fg_r=0.8,
                  fg_g=0.8,
                  fg_b=0.8,
                )

                // Input field
                buffer.draw_text("Input:", 4_U, 16_U)
                buffer.fill_rect(12_U, 16_U, 30_U, 1_U, 0.1, 0.1, 0.15, 1.0)
                buffer.draw_text(
                  text_input,
                  13_U,
                  16_U,
                  fg_r=0.9,
                  fg_g=0.9,
                  fg_b=0.9,
                )

                // Toggle
                buffer.draw_text("Dark Mode:", 4_U, 19_U)
                buffer.fill_rect(16_U, 19_U, 6_U, 1_U, 0.2, 0.6, 0.3, 1.0)
                buffer.draw_text("ON", 18_U, 19_U, fg_r=1.0, fg_g=1.0, fg_b=1.0)
              }
              2 => { // Layout
                buffer.draw_text(
                  "📐 Layout System (Yoga)",
                  4_U,
                  8_U,
                  fg_r=0.8,
                  fg_g=0.8,
                  fg_b=0.9,
                  bold=true,
                )

                // Flexbox demo
                buffer.fill_rect(4_U, 11_U, 30_U, 15_U, 0.1, 0.1, 0.15, 1.0)
                buffer.draw_text(
                  "Flex Container",
                  5_U,
                  12_U,
                  fg_r=0.6,
                  fg_g=0.6,
                  fg_b=0.7,
                )

                // Child boxes
                buffer.fill_rect(6_U, 14_U, 12_U, 4_U, 0.2, 0.3, 0.4, 1.0)
                buffer.draw_text("Item 1", 8_U, 15_U)
                buffer.fill_rect(20_U, 14_U, 12_U, 4_U, 0.3, 0.2, 0.4, 1.0)
                buffer.draw_text("Item 2", 22_U, 15_U)
                buffer.fill_rect(6_U, 19_U, 26_U, 4_U, 0.4, 0.2, 0.3, 1.0)
                buffer.draw_text("Stretched Item", 14_U, 20_U)

                // Grid demo
                buffer.fill_rect(38_U, 11_U, 30_U, 15_U, 0.1, 0.1, 0.15, 1.0)
                buffer.draw_text(
                  "Grid Layout",
                  39_U,
                  12_U,
                  fg_r=0.6,
                  fg_g=0.6,
                  fg_b=0.7,
                )

                // Grid cells
                for row = 0; row < 3; row = row + 1 {
                  for col = 0; col < 3; col = col + 1 {
                    let x = 40_U + (col * 9).reinterpret_as_uint()
                    let y = 14_U + (row * 4).reinterpret_as_uint()
                    buffer.fill_rect(
                      x,
                      y,
                      8_U,
                      3_U,
                      0.15 + row.to_double() * 0.1,
                      0.15 + col.to_double() * 0.1,
                      0.25,
                      1.0,
                    )
                    buffer.draw_text("[\{row},\{col}]", x + 1_U, y + 1_U)
                  }
                }
              }
              _ => { // About
                buffer.draw_text(
                  "ℹ️ About OneBit-TUI",
                  4_U,
                  8_U,
                  fg_r=0.8,
                  fg_g=0.8,
                  fg_b=0.9,
                  bold=true,
                )
                buffer.draw_text(
                  "A modern terminal UI library built with MoonBit", 4_U, 11_U,
                )
                buffer.draw_text(
                  "featuring high-performance rendering and", 4_U, 12_U,
                )
                buffer.draw_text(
                  "seamless FFI integration with OpenTUI.", 4_U, 13_U,
                )
                buffer.draw_text(
                  "Features:",
                  4_U,
                  16_U,
                  fg_r=0.7,
                  fg_g=0.9,
                  fg_b=0.7,
                )
                buffer.draw_text("• Component-based architecture", 4_U, 18_U)
                buffer.draw_text(
                  "• Yoga layout engine integration", 4_U, 19_U,
                )
                buffer.draw_text(
                  "• Mouse and keyboard event handling", 4_U, 20_U,
                )
                buffer.draw_text(
                  "• Theme support with RGBA colors", 4_U, 21_U,
                )
                buffer.draw_text(
                  "• Cross-platform terminal compatibility", 4_U, 22_U,
                )
                buffer.draw_text(
                  "Controls:",
                  4_U,
                  25_U,
                  fg_r=0.9,
                  fg_g=0.7,
                  fg_b=0.7,
                )
                buffer.draw_text("Tab/Shift+Tab - Switch tabs", 4_U, 27_U)
                buffer.draw_text("↑/↓ - Navigate items", 4_U, 28_U)
                buffer.draw_text("Enter - Select", 4_U, 29_U)
                buffer.draw_text("q/ESC - Quit", 4_U, 30_U)
              }
            }

            // Draw footer
            let footer_y = height - 2_U
            buffer.fill_rect(
              0_U,
              footer_y - 1_U,
              width,
              3_U,
              0.08,
              0.08,
              0.12,
              1.0,
            )
            buffer.draw_text(
              "[Tab] Switch • [↑↓] Navigate • [Enter] Select • [q] Quit",
              2_U,
              footer_y,
              fg_r=0.5,
              fg_g=0.5,
              fg_b=0.6,
            )

            // Show modal if active
            if show_modal {
              let modal_w = 40_U
              let modal_h = 10_U
              let modal_x = (width - modal_w) / 2_U
              let modal_y = (height - modal_h) / 2_U

              // Shadow
              buffer.fill_rect(
                modal_x + 2_U,
                modal_y + 1_U,
                modal_w,
                modal_h,
                0.0,
                0.0,
                0.0,
                0.5,
              )

              // Modal
              buffer.fill_rect(
                modal_x, modal_y, modal_w, modal_h, 0.15, 0.15, 0.2, 1.0,
              )
              buffer.draw_text(
                "✨ Success!",
                modal_x + 2_U,
                modal_y + 2_U,
                fg_r=0.4,
                fg_g=0.9,
                fg_b=0.4,
                bold=true,
              )
              buffer.draw_text(
                "Component loaded successfully",
                modal_x + 2_U,
                modal_y + 4_U,
              )
              buffer.draw_text(
                "[Enter] to close",
                modal_x + 2_U,
                modal_y + 7_U,
                fg_r=0.6,
                fg_g=0.6,
                fg_b=0.7,
              )
            }

            // Render frame
            renderer.render()

            // Update progress animation
            progress = progress + 0.01
            if progress > 1.0 {
              progress = 0.0
            }

            // Handle input
            match @ffi.poll_input_event() {
              @ffi.InputEvent::Key(key) =>
                match key {
                  @ffi.KeyEvent::Char(113) | @ffi.KeyEvent::Escape => // 'q' or ESC
                    running = false
                  @ffi.KeyEvent::Tab =>
                    current_tab = (current_tab + 1) % tabs.length()
                  @ffi.KeyEvent::ArrowUp =>
                    if selected_item > 0 {
                      selected_item = selected_item - 1
                    }
                  @ffi.KeyEvent::ArrowDown =>
                    if selected_item < list_items.length() - 1 {
                      selected_item = selected_item + 1
                    }
                  @ffi.KeyEvent::Enter => show_modal = not(show_modal)
                  @ffi.KeyEvent::Char(c) if c >= 32 && c < 127 =>
                    if text_input.length() < 25 {
                      text_input = text_input + c.unsafe_to_char().to_string()
                    }
                  @ffi.KeyEvent::Backspace =>
                    if text_input.length() > 0 {
                      text_input = text_input.substring(
                        end=text_input.length() - 1,
                      )
                    }
                  _ => ()
                }
              @ffi.InputEvent::MouseDown(x, y, _) =>
                // Check tab clicks
                if y < 6 {
                  let mut tab_x = 2
                  for i = 0; i < tabs.length(); i = i + 1 {
                    let tab_width = tabs[i].length() + 5
                    if x >= tab_x && x < tab_x + tab_width {
                      current_tab = i
                      break
                    }
                    tab_x = tab_x + tab_width
                  }
                }
              @ffi.InputEvent::Resize(new_width, new_height) =>
                renderer.resize(new_width, new_height)
              _ => @ffi.sleep_ms(16) // ~60 FPS
            }
          }

          // Cleanup
          session.cleanup()
          renderer.destroy()
          println("\nThanks for trying OneBit-TUI!")
        }
      }
    }
  }
}
