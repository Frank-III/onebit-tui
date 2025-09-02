// Plugin Showcase Demo - Demonstrating the plugin system

fn main {
  let mut app = @core.App::new()
  let theme_manager = @theming.ThemeManager::new()
  let plugin_manager = @plugins.PluginManager::new(theme_manager)
  
  // Title
  let title = @components.Text::new(25, 1, 30, "Plugin System Demo")
  app.add_component(title.as_renderable())
  
  // Plugin list
  let plugin_box = @components.Box::new(5, 4, 35, 16)
  plugin_box.set_title("Available Plugins")
  
  let plugin_items = [
    "Weather Widget",
    "Clock Plugin",
    "Custom Theme Pack",
    "Chart Extensions",
    "File Manager",
    "Terminal Shortcuts"
  ]
  let plugin_list = @components.List::new(7, 6, 31, 12, plugin_items)
  plugin_box.add_child(plugin_list.as_renderable())
  app.add_component(plugin_box.as_renderable())
  
  // Plugin details
  let details_box = @components.Box::new(42, 4, 35, 16)
  details_box.set_title("Plugin Details")
  
  let details_text = @components.Text::new(44, 6, 31, "Select a plugin to view details")
  details_box.add_child(details_text.as_renderable())
  app.add_component(details_box.as_renderable())
  
  // Plugin controls
  let controls_box = @components.Box::new(5, 21, 72, 6)
  controls_box.set_title("Controls")
  
  let controls_text = @components.Text::new(
    7, 23, 68,
    "↑/↓: Select | Enter: Enable/Disable | i: Install | u: Uninstall | r: Reload | q: Quit"
  )
  controls_box.add_child(controls_text.as_renderable())
  app.add_component(controls_box.as_renderable())
  
  // Plugin status
  let mut plugin_states = Array::make(6, false)
  
  // Sample plugins
  let weather_plugin = @plugins.ExamplePlugin::new()
  let theme_plugin = @plugins.ThemePlugin::new([
    ("ocean", create_ocean_theme()),
    ("forest", create_forest_theme()),
    ("sunset", create_sunset_theme())
  ])
  
  // Register plugins
  match plugin_manager.register(weather_plugin) {
    Ok(_) => println("Weather plugin registered")
    Err(e) => println("Failed to register weather plugin: " + e)
  }
  
  match plugin_manager.register(theme_plugin) {
    Ok(_) => println("Theme plugin registered")
    Err(e) => println("Failed to register theme plugin: " + e)
  }
  
  // Function to update details
  fn update_details(index : Int) {
    let info = match index {
      0 => "Weather Widget v1.0.0\n\n" +
           "Displays current weather information\n" +
           "in your terminal UI.\n\n" +
           "Features:\n" +
           "- Real-time updates\n" +
           "- Multiple cities\n" +
           "- Weather forecasts"
      1 => "Clock Plugin v2.1.0\n\n" +
           "Adds various clock widgets including\n" +
           "analog and digital displays.\n\n" +
           "Features:\n" +
           "- Multiple time zones\n" +
           "- Customizable formats\n" +
           "- Alarm functionality"
      2 => "Custom Theme Pack v1.5.0\n\n" +
           "Collection of beautiful themes:\n" +
           "- Ocean\n" +
           "- Forest\n" +
           "- Sunset\n\n" +
           "Status: " + if plugin_states[2] { "Enabled" } else { "Disabled" }
      3 => "Chart Extensions v3.0.0\n\n" +
           "Additional chart types:\n" +
           "- Pie charts\n" +
           "- Scatter plots\n" +
           "- Heatmaps\n" +
           "- 3D visualizations"
      4 => "File Manager v1.2.0\n\n" +
           "Full-featured file manager with:\n" +
           "- Tree view\n" +
           "- File operations\n" +
           "- Preview pane\n" +
           "- Search functionality"
      5 => "Terminal Shortcuts v1.0.0\n\n" +
           "Custom keyboard shortcuts for\n" +
           "common terminal operations.\n\n" +
           "Fully configurable with\n" +
           "visual shortcut editor."
      _ => "No plugin selected"
    }
    details_text.set_content(info)
  }
  
  // Run the app
  app.run(fn(event) {
    match event {
      @core.Event::Key(key) => {
        match key {
          @core.Key::Char('q') => return false
          @core.Key::Up => {
            plugin_list.select_previous()
            update_details(plugin_list.get_selected_index())
          }
          @core.Key::Down => {
            plugin_list.select_next()
            update_details(plugin_list.get_selected_index())
          }
          @core.Key::Enter => {
            let index = plugin_list.get_selected_index()
            plugin_states[index] = not(plugin_states[index])
            
            // In real implementation, would enable/disable plugin
            if plugin_states[index] {
              println("Enabling plugin: " + plugin_items[index])
            } else {
              println("Disabling plugin: " + plugin_items[index])
            }
            update_details(index)
          }
          @core.Key::Char('i') => {
            let index = plugin_list.get_selected_index()
            println("Installing plugin: " + plugin_items[index])
          }
          @core.Key::Char('u') => {
            let index = plugin_list.get_selected_index()
            println("Uninstalling plugin: " + plugin_items[index])
            plugin_states[index] = false
          }
          @core.Key::Char('r') => {
            println("Reloading plugins...")
          }
          _ => ()
        }
      }
      _ => ()
    }
    true
  })
}

// Helper functions to create sample themes
fn create_ocean_theme() -> @theming.Theme {
  let theme = @theming.Theme::default()
  theme.colors.primary = @core.RGBA::from_hex("#006994")
  theme.colors.secondary = @core.RGBA::from_hex("#00A8E8")
  theme.colors.background = @core.RGBA::from_hex("#003459")
  theme
}

fn create_forest_theme() -> @theming.Theme {
  let theme = @theming.Theme::default()
  theme.colors.primary = @core.RGBA::from_hex("#2D5016")
  theme.colors.secondary = @core.RGBA::from_hex("#73A942")
  theme.colors.background = @core.RGBA::from_hex("#1C3409")
  theme
}

fn create_sunset_theme() -> @theming.Theme {
  let theme = @theming.Theme::default()
  theme.colors.primary = @core.RGBA::from_hex("#F07167")
  theme.colors.secondary = @core.RGBA::from_hex("#FED9B7")
  theme.colors.background = @core.RGBA::from_hex("#300A0A")
  theme
}