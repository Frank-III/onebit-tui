// MoonBit OpenTUI Showcase - Unique features demonstration

fn main {
  let mut app = App::new()
  let animation_manager = @animation.AnimationManager::new()
  let theme_manager = @theming.ThemeManager::new()
  let plugin_manager = @plugins.PluginManager::new(theme_manager)
  
  // Animated title with gradient effect
  let title = @animation.AnimatedComponent::new(15, 1, 50, 3)
  let title_text = @components.Text::new(17, 2, 46, "🌙 MoonBit OpenTUI Feature Showcase")
  title.base.add_child(title_text.as_renderable())
  title.bounce_in(1500)
  
  // Feature grid using Flexbox
  let main_container = @components.Flexbox::new(
    2, 5, 76, 22,
    @components.FlexDirection::Horizontal
  )
  
  // Left panel - Component showcase
  let component_panel = @components.Box::new(0, 0, 24, 20)
  component_panel.set_title("Rich Components")
  
  // Chart with real-time data
  let chart_data = Array::make(5, ("", 0.0))
  for i = 0; i < 5; i = i + 1 {
    chart_data[i] = ("Item " + (i + 1).to_string(), @math.random() * 100.0)
  }
  let chart = @components.Chart::new(2, 2, 20, 8, @components.ChartType::Bar, chart_data)
  
  // Spinner with custom style
  let spinner = @components.Spinner::new(2, 11, @components.SpinnerStyle::Dots, "Processing...")
  
  // Progress with gradient
  let progress = @components.ProgressBar::new(2, 13, 20, 1)
  progress.set_value(0.0)
  progress.set_gradient(true)
  
  component_panel.add_child(chart.as_renderable())
  component_panel.add_child(spinner.as_renderable())
  component_panel.add_child(progress.as_renderable())
  
  // Center panel - Animation showcase
  let animation_panel = @components.Box::new(26, 0, 24, 20)
  animation_panel.set_title("Animations")
  
  // Animated boxes
  let box1 = @animation.AnimatedComponent::new(28, 2, 8, 3)
  let box2 = @animation.AnimatedComponent::new(38, 2, 8, 3)
  let box3 = @animation.AnimatedComponent::new(28, 7, 8, 3)
  let box4 = @animation.AnimatedComponent::new(38, 7, 8, 3)
  
  animation_manager.register(box1)
  animation_manager.register(box2)
  animation_manager.register(box3)
  animation_manager.register(box4)
  
  animation_panel.add_child(box1.as_renderable())
  animation_panel.add_child(box2.as_renderable())
  animation_panel.add_child(box3.as_renderable())
  animation_panel.add_child(box4.as_renderable())
  
  // Right panel - Theme preview
  let theme_panel = @components.Box::new(52, 0, 22, 20)
  theme_panel.set_title("Themes & Plugins")
  
  let theme_list = @components.List::new(54, 2, 18, 8, [
    "🌊 Ocean",
    "🌲 Forest", 
    "🌅 Sunset",
    "🌙 Moonlight"
  ])
  
  let plugin_info = @components.Text::new(
    54, 12, 18,
    "Plugins:\n✓ Weather\n✓ Clock\n✓ Charts+"
  )
  
  theme_panel.add_child(theme_list.as_renderable())
  theme_panel.add_child(plugin_info.as_renderable())
  
  // Add panels to container
  main_container.add_child(component_panel.as_renderable())
  main_container.add_child(animation_panel.as_renderable())
  main_container.add_child(theme_panel.as_renderable())
  
  // Add to app
  app.add_component(title.as_renderable())
  app.add_component(main_container.as_renderable())
  animation_manager.register(title)
  
  // Status bar
  let status = @components.Text::new(
    2, 28, 76,
    "Tab: Switch panels | Space: Toggle animations | t: Change theme | q: Quit"
  )
  app.add_component(status.as_renderable())
  
  // Create complex animations
  let timeline = @animation.create_timeline()
  
  // Animate progress bar
  timeline.add_animation(0, {
    duration: 3000,
    ease: @animation.InOutQuad,
    on_update: Some(fn(anim) {
      progress.set_value(anim.progress)
    }),
    on_complete: None,
    on_start: None,
    on_loop: None,
    loop: @animation.Infinite,
    loop_delay: 500,
    alternate: true,
    once: false,
  })
  
  // Animate chart data
  timeline.add_animation(0, {
    duration: 2000,
    ease: @animation.InOutSine,
    on_update: Some(fn(anim) {
      for i = 0; i < 5; i = i + 1 {
        let base = 30.0
        let variation = @math.sin(anim.progress * @math.pi * 2.0 + i.to_double() * 0.8) * 30.0
        chart_data[i] = ("Item " + (i + 1).to_string(), base + variation)
      }
    }),
    on_complete: None,
    on_start: None,
    on_loop: None,
    loop: @animation.Infinite,
    loop_delay: 0,
    alternate: false,
    once: false,
  })
  
  // Choreographed box animations
  let box_timeline = @animation.create_timeline()
  
  // Wave animation for boxes
  box_timeline
    .add_animation(0, {
      duration: 800,
      ease: @animation.OutBack,
      on_start: Some(fn() { box1.slide_in_from_left(800) }),
      on_update: None,
      on_complete: None,
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
    .add_animation(200, {
      duration: 800,
      ease: @animation.OutBack,
      on_start: Some(fn() { box2.slide_in_from_right(50, 800) }),
      on_update: None,
      on_complete: None,
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
    .add_animation(400, {
      duration: 800,
      ease: @animation.OutBack,
      on_start: Some(fn() { box3.bounce_in(800) }),
      on_update: None,
      on_complete: None,
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
    .add_animation(600, {
      duration: 800,
      ease: @animation.OutBack,
      on_start: Some(fn() { box4.fade_to(1.0, 800, @animation.OutQuad) }),
      on_update: None,
      on_complete: None,
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
  
  timeline.play()
  box_timeline.play()
  
  // State
  let mut current_panel = 0
  let mut animations_paused = false
  let mut frame = 0
  
  // Run app
  app.run(fn(event) {
    match event {
      Event::Key(key) => {
        match key {
          Key::Char('q') => return false
          Key::Tab => {
            current_panel = (current_panel + 1) % 3
            // Update focus indicator
          }
          Key::Space => {
            if animations_paused {
              timeline.play()
              animations_paused = false
            } else {
              timeline.pause()
              animations_paused = true
            }
          }
          Key::Char('t') => {
            match theme_list.get_selected_index() {
              0 => theme_manager.set_theme("ocean")
              1 => theme_manager.set_theme("forest")
              2 => theme_manager.set_theme("sunset")
              3 => theme_manager.set_theme("default")
              _ => ()
            }
          }
          Key::Up => {
            if current_panel == 2 {
              theme_list.select_previous()
            }
          }
          Key::Down => {
            if current_panel == 2 {
              theme_list.select_next()
            }
          }
          _ => ()
        }
      }
      Event::Tick => {
        // Update animations
        if not(animations_paused) {
          animation_manager.update(frame * 16)
          timeline.update(16)
        }
        
        // Update spinner
        spinner.tick()
        
        frame = frame + 1
      }
      _ => ()
    }
    true
  })
}
