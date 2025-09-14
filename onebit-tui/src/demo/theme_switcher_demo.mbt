// Theme Switcher Demo - Showcasing theming capabilities

fn main {
  let mut app = App::new()
  let theme_manager = @theming.ThemeManager::new()
  
  // Title
  let title = @components.Text::new(25, 1, 30, "Theme Switcher Demo")
  app.add_component(title.as_renderable())
  
  // Theme selector
  let theme_box = @components.Box::new(5, 4, 30, 12)
  theme_box.set_title("Select Theme")
  
  let theme_items = [
    "Default (Dark)",
    "Light",
    "High Contrast", 
    "Solarized Dark"
  ]
  let theme_list = @components.List::new(7, 6, 26, 8, theme_items)
  theme_box.add_child(theme_list.as_renderable())
  app.add_component(theme_box.as_renderable())
  
  // Preview panel
  let preview_box = @components.Box::new(40, 4, 35, 20)
  preview_box.set_title("Preview")
  
  // Sample components for preview
  let sample_button = @components.Button::new(42, 6, 15, "Sample Button")
  let sample_toggle = @components.Toggle::new(42, 8, "Feature", true)
  
  let sample_progress = @components.ProgressBar::new(42, 10, 30, 1)
  sample_progress.set_value(0.7)
  sample_progress.set_label("70%")
  
  let sample_table_headers = ["Name", "Value"]
  let sample_table_data = [
    ["Primary", "Blue"],
    ["Success", "Green"],
    ["Warning", "Yellow"],
    ["Error", "Red"]
  ]
  let sample_table = @components.Table::new(42, 13, 30, 8, sample_table_headers, sample_table_data)
  
  preview_box.add_child(sample_button.as_renderable())
  preview_box.add_child(sample_toggle.as_renderable())
  preview_box.add_child(sample_progress.as_renderable())
  preview_box.add_child(sample_table.as_renderable())
  app.add_component(preview_box.as_renderable())
  
  // Color palette display
  let palette_box = @components.Box::new(5, 18, 70, 8)
  palette_box.set_title("Color Palette")
  
  let palette_text = @components.Text::new(7, 20, 66, "")
  palette_box.add_child(palette_text.as_renderable())
  app.add_component(palette_box.as_renderable())
  
  // Help text
  let help = @components.Text::new(
    5, 27, 70,
    "↑/↓: Select theme | Enter: Apply | c: Create custom | q: Quit"
  )
  app.add_component(help.as_renderable())
  
  // Function to update palette display
  fn update_palette_display() {
    let current = theme_manager.get_current_theme()
    let palette_info = "Primary: " + color_to_string(current.colors.primary) + "\n" +
                      "Secondary: " + color_to_string(current.colors.secondary) + "\n" +
                      "Background: " + color_to_string(current.colors.background) + "\n" +
                      "Text: " + color_to_string(current.colors.text)
    palette_text.set_content(palette_info)
  }
  
  // Initial palette display
  update_palette_display()
  
  // Run the app
  app.run(fn(event) {
    match event {
      Event::Key(key) => {
        match key {
          Key::Char('q') => return false
          Key::Up => {
            theme_list.select_previous()
          }
          Key::Down => {
            theme_list.select_next()
          }
          Key::Enter => {
            match theme_list.get_selected_index() {
              0 => theme_manager.set_theme("default")
              1 => theme_manager.set_theme("light")
              2 => theme_manager.set_theme("high_contrast")
              3 => theme_manager.set_theme("solarized_dark")
              _ => ()
            }
            update_palette_display()
            // In real implementation, would update all components with new theme
          }
          Key::Char('c') => {
            // Show custom theme creator
            show_custom_theme_creator()
          }
          _ => ()
        }
      }
      _ => ()
    }
    true
  })
}

fn color_to_string(color : RGBA) -> String {
  "RGB(" + (color.r * 255.0).to_int().to_string() + ", " +
          (color.g * 255.0).to_int().to_string() + ", " +
          (color.b * 255.0).to_int().to_string() + ")"
}

fn show_custom_theme_creator() -> Unit {
  // In a real implementation, this would show a modal
  // for creating custom themes
  println("Custom theme creator would appear here")
}