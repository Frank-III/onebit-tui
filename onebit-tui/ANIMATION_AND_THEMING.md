# Animation and Theming Implementation

## Animation System

We've implemented a comprehensive animation system for OpenTUI MoonBit that provides feature parity with the TypeScript version.

### Features

1. **Timeline-based Animation**
   - Support for sequencing multiple animations
   - Callbacks at specific time points
   - Looping and alternating animations
   - Play/pause/restart controls

2. **Property Animation**
   - Animate any numeric property
   - Support for all standard easing functions
   - Progress callbacks
   - Completion handlers

3. **Easing Functions**
   - Linear, InQuad, OutQuad, InOutQuad
   - InExpo, OutExpo, InOutSine
   - OutBounce, OutElastic, InBounce
   - InCirc, OutCirc, InOutCirc
   - InBack, OutBack, InOutBack

4. **Animated Components**
   - `AnimatedComponent` wrapper for easy animation
   - Built-in animations: fade, slide, bounce
   - Animation manager for coordinating multiple animations

### Usage Example

```moonbit
// Create animated component
let box = AnimatedComponent::new(10, 10, 20, 5)

// Animate position
box.animate_to(50, 20, 1000, OutBack)

// Fade in
box.fade_to(1.0, 500, OutQuad)

// Use timeline for complex animations
let timeline = create_timeline()
timeline
  .add_animation(0, move_animation)
  .call(fn() { println("Halfway!") }, 500)
  .add_animation(1000, scale_animation)
```

## Theming System

We've implemented a flexible theming system that allows for easy customization of the UI.

### Features

1. **Theme Structure**
   - Color palette (primary, secondary, semantic colors)
   - Typography settings
   - Spacing scale
   - Border themes
   - Shadow definitions

2. **Built-in Themes**
   - Default (dark)
   - Light
   - High contrast
   - Solarized dark

3. **Theme Manager**
   - Register custom themes
   - Switch themes at runtime
   - Theme context for components

### Usage Example

```moonbit
// Create theme manager
let theme_manager = ThemeManager::new()

// Switch to light theme
theme_manager.set_theme("light")

// Register custom theme
let custom_theme = Theme {
  name: "Custom",
  colors: custom_palette,
  // ...
}
theme_manager.register_theme("custom", custom_theme)
```

## Plugin System

We've implemented a plugin system for extending OpenTUI functionality.

### Features

1. **Plugin Lifecycle**
   - Load/unload hooks
   - Enable/disable functionality
   - Metadata and dependencies

2. **Plugin Context**
   - Access to theme manager
   - Component registry
   - Event bus for communication

3. **Built-in Plugin Types**
   - Theme plugins for custom themes
   - Component plugins for custom components
   - Example plugin as reference

### Usage Example

```moonbit
// Create plugin
let my_plugin = MyCustomPlugin::new()

// Register with plugin manager
let plugin_manager = PluginManager::new(theme_manager)
plugin_manager.register(my_plugin)

// Enable plugin
plugin_manager.enable("my_plugin")
```

## Next Steps

1. **Integration with Components**
   - Add theme support to all components
   - Implement animated versions of standard components
   - Create plugin hooks in component lifecycle

2. **Performance Optimization**
   - Optimize animation frame updates
   - Implement dirty region tracking for animations
   - Cache theme calculations

3. **Additional Features**
   - Spring physics animations
   - Gesture-based animations
   - Theme transitions with animation
   - Hot-reload for plugins

The animation and theming systems provide a solid foundation for creating dynamic, customizable terminal UIs with OpenTUI.
