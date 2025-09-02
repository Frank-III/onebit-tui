// Plugin system for OpenTUI

// Plugin metadata
pub struct PluginMetadata {
  name : String
  version : String
  author : String
  description : String
  dependencies : Array[String]
}

// Plugin lifecycle hooks
pub trait Plugin {
  fn metadata(Self) -> PluginMetadata
  fn on_load(Self) -> Unit
  fn on_unload(Self) -> Unit
  fn on_enable(Self) -> Unit
  fn on_disable(Self) -> Unit
}

// Plugin context for accessing framework features
pub struct PluginContext {
  theme_manager : @theming.ThemeManager
  component_registry : ComponentRegistry
  event_bus : EventBus
}

// Component registry for plugins to register custom components
pub struct ComponentRegistry {
  mut components : @core.Map[ComponentFactory]
}

pub struct ComponentFactory {
  name : String
  create : () -> @core.BaseRenderable
}

pub fn ComponentRegistry::new() -> ComponentRegistry {
  {
    components: @core.Map::new(),
  }
}

pub fn register_component(self : ComponentRegistry, name : String, factory : ComponentFactory) -> Unit {
  self.components.set(name, factory)
}

pub fn create_component(self : ComponentRegistry, name : String) -> Option[@core.BaseRenderable] {
  match self.components.get(name) {
    Some(factory) => Some((factory.create)())
    None => None
  }
}

// Event bus for plugin communication
pub struct EventBus {
  mut listeners : @core.Map[Array[EventListener]]
}

pub struct EventListener {
  id : String
  handler : (Event) -> Unit
}

pub enum Event {
  ThemeChanged(String)
  ComponentCreated(String)
  ComponentDestroyed(String)
  Custom(String, Any)
}

pub fn EventBus::new() -> EventBus {
  {
    listeners: @core.Map::new(),
  }
}

pub fn subscribe(self : EventBus, event_type : String, listener : EventListener) -> Unit {
  match self.listeners.get(event_type) {
    Some(listeners) => listeners.push(listener)
    None => {
      let listeners = [listener]
      self.listeners.set(event_type, listeners)
    }
  }
}

pub fn emit(self : EventBus, event : Event) -> Unit {
  let event_type = match event {
    ThemeChanged(_) => "theme_changed"
    ComponentCreated(_) => "component_created"
    ComponentDestroyed(_) => "component_destroyed"
    Custom(type_name, _) => type_name
  }
  
  match self.listeners.get(event_type) {
    Some(listeners) => {
      for listener in listeners {
        (listener.handler)(event)
      }
    }
    None => ()
  }
}

// Plugin manager
pub struct PluginManager {
  mut plugins : @core.Map[PluginInstance]
  mut context : PluginContext
}

pub struct PluginInstance {
  plugin : Plugin
  enabled : Bool
  metadata : PluginMetadata
}

pub fn PluginManager::new(theme_manager : @theming.ThemeManager) -> PluginManager {
  {
    plugins: @core.Map::new(),
    context: {
      theme_manager,
      component_registry: ComponentRegistry::new(),
      event_bus: EventBus::new(),
    },
  }
}

pub fn register(self : PluginManager, plugin : Plugin) -> Result[Unit, String] {
  let metadata = plugin.metadata()
  
  // Check if plugin already exists
  match self.plugins.get(metadata.name) {
    Some(_) => Err("Plugin already registered: " + metadata.name)
    None => {
      // Check dependencies
      for dep in metadata.dependencies {
        match self.plugins.get(dep) {
          None => return Err("Missing dependency: " + dep)
          Some(_) => ()
        }
      }
      
      // Register plugin
      let instance = {
        plugin,
        enabled: false,
        metadata,
      }
      
      self.plugins.set(metadata.name, instance)
      plugin.on_load()
      Ok(())
    }
  }
}

pub fn enable(self : PluginManager, name : String) -> Result[Unit, String] {
  match self.plugins.get(name) {
    Some(instance) => {
      if instance.enabled {
        Ok(())
      } else {
        instance.plugin.on_enable()
        instance.enabled = true
        self.context.event_bus.emit(Custom("plugin_enabled", name))
        Ok(())
      }
    }
    None => Err("Plugin not found: " + name)
  }
}

pub fn disable(self : PluginManager, name : String) -> Result[Unit, String] {
  match self.plugins.get(name) {
    Some(instance) => {
      if not(instance.enabled) {
        Ok(())
      } else {
        instance.plugin.on_disable()
        instance.enabled = false
        self.context.event_bus.emit(Custom("plugin_disabled", name))
        Ok(())
      }
    }
    None => Err("Plugin not found: " + name)
  }
}

// Example plugin implementation
pub struct ExamplePlugin {
  name : String
}

pub fn ExamplePlugin::new() -> ExamplePlugin {
  {
    name: "Example Plugin",
  }
}

pub fn metadata(self : ExamplePlugin) -> PluginMetadata {
  {
    name: "example",
    version: "1.0.0",
    author: "OpenTUI Team",
    description: "Example plugin demonstrating the plugin system",
    dependencies: [],
  }
}

pub fn on_load(self : ExamplePlugin) -> Unit {
  println("Example plugin loaded")
}

pub fn on_unload(self : ExamplePlugin) -> Unit {
  println("Example plugin unloaded")
}

pub fn on_enable(self : ExamplePlugin) -> Unit {
  println("Example plugin enabled")
}

pub fn on_disable(self : ExamplePlugin) -> Unit {
  println("Example plugin disabled")
}

// Plugin for adding custom themes
pub struct ThemePlugin {
  themes : Array[(String, @theming.Theme)]
}

pub fn ThemePlugin::new(themes : Array[(String, @theming.Theme)]) -> ThemePlugin {
  {
    themes,
  }
}

pub fn metadata(self : ThemePlugin) -> PluginMetadata {
  {
    name: "theme_plugin",
    version: "1.0.0",
    author: "Theme Author",
    description: "Custom theme collection",
    dependencies: [],
  }
}

pub fn on_load(self : ThemePlugin) -> Unit {
  // Themes will be registered when enabled
}

pub fn on_unload(self : ThemePlugin) -> Unit {
  // Nothing to do
}

pub fn on_enable(self : ThemePlugin) -> Unit {
  // Register themes with theme manager
  // Note: In real implementation, would access theme manager through context
  println("Theme plugin enabled - would register " + self.themes.length().to_string() + " themes")
}

pub fn on_disable(self : ThemePlugin) -> Unit {
  // Unregister themes
  println("Theme plugin disabled")
}

// Plugin for adding custom components
pub struct ComponentPlugin {
  components : Array[ComponentFactory]
}

pub fn ComponentPlugin::new(components : Array[ComponentFactory]) -> ComponentPlugin {
  {
    components,
  }
}

pub fn metadata(self : ComponentPlugin) -> PluginMetadata {
  {
    name: "component_plugin",
    version: "1.0.0",
    author: "Component Author",
    description: "Custom component collection",
    dependencies: [],
  }
}

pub fn on_load(self : ComponentPlugin) -> Unit {
  println("Component plugin loaded")
}

pub fn on_unload(self : ComponentPlugin) -> Unit {
  println("Component plugin unloaded")
}

pub fn on_enable(self : ComponentPlugin) -> Unit {
  // Register components
  println("Component plugin enabled - would register " + self.components.length().to_string() + " components")
}

pub fn on_disable(self : ComponentPlugin) -> Unit {
  // Unregister components
  println("Component plugin disabled")
}
