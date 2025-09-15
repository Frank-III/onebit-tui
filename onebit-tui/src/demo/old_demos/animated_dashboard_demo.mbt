// Animated Dashboard Demo - Showcasing real-time updates and animations

fn main {
  let mut app = App::new()
  let animation_manager = @animation.AnimationManager::new()
  
  // Dashboard title with animated color
  let title = @animation.AnimatedComponent::new(20, 1, 40, 3)
  let title_text = @components.Text::new(22, 2, 36, "System Monitor Dashboard")
  title.base.add_child(title_text.as_renderable())
  
  // CPU usage chart with animation
  let cpu_box = @components.Box::new(2, 5, 38, 12)
  cpu_box.set_title("CPU Usage")
  
  let cpu_data = Array::make(4, ("", 0.0))
  for i = 0; i < 4; i = i + 1 {
    cpu_data[i] = ("Core " + i.to_string(), @math.random() * 100.0)
  }
  
  let cpu_chart = @components.Chart::new(
    4, 7, 34, 8,
    @components.ChartType::Bar,
    cpu_data
  )
  cpu_box.add_child(cpu_chart.as_renderable())
  
  // Memory usage with animated progress bar
  let memory_box = @components.Box::new(42, 5, 36, 12)
  memory_box.set_title("Memory Usage")
  
  let memory_progress = @components.ProgressBar::new(44, 8, 32, 1)
  memory_progress.set_value(0.65)
  memory_progress.set_label("65% (10.4 GB / 16 GB)")
  memory_box.add_child(memory_progress.as_renderable())
  
  // Network traffic with live updates
  let network_box = @components.Box::new(2, 18, 38, 10)
  network_box.set_title("Network Traffic")
  
  let network_data = Array::make(20, 0.0)
  let network_chart = @components.Chart::new(
    4, 20, 34, 6,
    @components.ChartType::Line,
    network_data.map(fn(v) { ("", v) })
  )
  network_box.add_child(network_chart.as_renderable())
  
  // Process list with scrolling
  let process_box = @components.Box::new(42, 18, 36, 10)
  process_box.set_title("Top Processes")
  
  let process_headers = ["PID", "Name", "CPU%", "Memory"]
  let process_data = [
    ["1234", "chrome", "45.2", "2.1GB"],
    ["5678", "node", "12.3", "512MB"],
    ["9012", "moonbit", "8.7", "256MB"],
    ["3456", "terminal", "3.2", "128MB"],
  ]
  
  let process_table = @components.Table::new(44, 20, 32, 6, process_headers, process_data)
  process_box.add_child(process_table.as_renderable())
  
  // Add all components
  app.add_component(title.as_renderable())
  app.add_component(cpu_box.as_renderable())
  app.add_component(memory_box.as_renderable())
  app.add_component(network_box.as_renderable())
  app.add_component(process_box.as_renderable())
  
  // Register animated components
  animation_manager.register(title)
  
  // Create animations
  let timeline = @animation.create_timeline()
  
  // Animate title position
  title.bounce_in(1000)
  
  // Animate CPU bars
  timeline.add_animation(0, {
    duration: 2000,
    ease: @animation.InOutSine,
    on_update: Some(fn(anim) {
      for i = 0; i < 4; i = i + 1 {
        let value = 20.0 + @math.sin(anim.progress * @math.pi * 2.0 + i.to_double() * 0.5) * 30.0
        cpu_data[i] = ("Core " + i.to_string(), value)
      }
      // Update chart data
    }),
    on_complete: None,
    on_start: None,
    on_loop: None,
    loop: @animation.Infinite,
    loop_delay: 0,
    alternate: false,
    once: false,
  })
  
  // Animate memory usage
  timeline.add_animation(0, {
    duration: 3000,
    ease: @animation.OutQuad,
    on_update: Some(fn(anim) {
      let value = 0.5 + anim.progress * 0.3
      memory_progress.set_value(value)
      let gb = (value * 16.0 * 10.0).to_int().to_double() / 10.0
      memory_progress.set_label((value * 100.0).to_int().to_string() + "% (" + gb.to_string() + " GB / 16 GB)")
    }),
    on_complete: None,
    on_start: None,
    on_loop: None,
    loop: @animation.Count(1),
    loop_delay: 0,
    alternate: false,
    once: false,
  })
  
  // Animate network traffic
  timeline.add_animation(0, {
    duration: 100,
    ease: @animation.Linear,
    on_update: Some(fn(_anim) {
      // Shift data left
      for i = 0; i < 19; i = i + 1 {
        network_data[i] = network_data[i + 1]
      }
      // Add new random value
      network_data[19] = @math.random() * 100.0
      // Update chart
    }),
    on_complete: None,
    on_start: None,
    on_loop: None,
    loop: @animation.Infinite,
    loop_delay: 0,
    alternate: false,
    once: false,
  })
  
  timeline.play()
  
  // Status bar
  let status = @components.Text::new(
    2, 29, 76,
    "Press 'q' to quit | Tab: Switch focus | Space: Pause animations"
  )
  app.add_component(status.as_renderable())
  
  // Run the app
  let mut frame = 0
  let mut paused = false
  
  app.run(fn(event) {
    match event {
      Event::Key(key) => {
        match key {
          Key::Char('q') => return false
          Key::Space => {
            if paused {
              timeline.play()
            } else {
              timeline.pause()
            }
            paused = not(paused)
          }
          Key::Tab => {
            // Switch focus between components
          }
          _ => ()
        }
      }
      Event::Tick => {
        // Update animations
        if not(paused) {
          animation_manager.update(frame * 16) // 60 FPS
          timeline.update(16)
        }
        frame = frame + 1
      }
      _ => ()
    }
    true
  })
}

// Math helpers
fn random() -> Double {
  // Simple pseudo-random for demo
  @math.sin((@time.now() * 9999.0).to_double()) * 0.5 + 0.5
}