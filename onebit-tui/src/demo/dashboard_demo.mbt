///| Dashboard Demo
///| Shows a system monitoring dashboard with various components

struct DashboardState {
  mut cpu_usage : Double
  mut memory_usage : Double
  mut disk_usage : Double
  mut network_in : Double
  mut network_out : Double
  mut process_count : Int
  mut uptime_seconds : Int
  
  // UI Components
  cpu_progress : @components.ProgressBar
  memory_progress : @components.ProgressBar
  disk_progress : @components.ProgressBar
  network_spinner : @components.Spinner
  loading_bar : @components.LoadingBar
  
  // Simulated data history
  cpu_history : FixedArray[Double]
  memory_history : FixedArray[Double]
  mut history_index : Int
}

pub fn run_dashboard_demo() -> Unit {
  println("=== OneBit-TUI Dashboard Demo ===")
  println("Features:")
  println("  📊 Real-time system monitoring")
  println("  📈 Progress bars and charts")
  println("  🔄 Loading animations")
  println("  ⌨️  Keyboard controls")
  println("")
  println("Controls:")
  println("  r: Refresh data")
  println("  p: Pause/Resume")
  println("  q/ESC: Quit")
  println("")
  println("Press any key to start...")
  
  // Initialize terminal session
  match @ffi.TerminalSession::new(
    raw_mode=true,
    mouse=true,
    resize_detection=true
  ) {
    None => {
      println("Failed to initialize terminal session")
      return
    }
    Some(session) => {
      let (width, height) = @ffi.get_terminal_size()
      
      // Initialize renderer
      match @ffi.Renderer::new(width, height) {
        None => {
          session.cleanup()
          println("Failed to initialize renderer")
          return
        }
        Some(renderer) => {
          // Initialize dashboard state
          let state = init_dashboard_state()
          
          // Run dashboard
          run_dashboard(renderer, state)
          
          // Cleanup
          renderer.destroy()
          session.cleanup()
          
          println("\nDashboard demo completed!")
        }
      }
    }
  }
}

fn init_dashboard_state() -> DashboardState {
  // Initialize history arrays
  let history_size = 60
  let cpu_history = FixedArray::make(history_size, 0.0)
  let memory_history = FixedArray::make(history_size, 0.0)
  
  // Initialize with some random data
  for i = 0; i < history_size; i = i + 1 {
    cpu_history[i] = 0.3 + @math.sin(i.to_double() * 0.01) * 0.2
    memory_history[i] = 0.5 + @math.cos(i.to_double() * 0.02) * 0.1
  }
  
  DashboardState::{
    cpu_usage: 0.45,
    memory_usage: 0.62,
    disk_usage: 0.38,
    network_in: 0.0,
    network_out: 0.0,
    process_count: 142,
    uptime_seconds: 0,
    
    cpu_progress: @components.ProgressBar::new(
      value=0.45,
      label="CPU Usage",
      style=@components.ProgressBarStyle::Gradient,
      bar_color=RGBA::new(0.2, 0.8, 0.4, 1.0),
      show_percentage=true
    ),
    
    memory_progress: @components.ProgressBar::new(
      value=0.62,
      label="Memory",
      style=@components.ProgressBarStyle::Solid,
      bar_color=RGBA::new(0.8, 0.6, 0.2, 1.0),
      show_percentage=true
    ),
    
    disk_progress: @components.ProgressBar::new(
      value=0.38,
      label="Disk Space",
      style=@components.ProgressBarStyle::Segmented(10),
      bar_color=RGBA::new(0.6, 0.4, 0.8, 1.0),
      show_percentage=true
    ),
    
    network_spinner: @components.Spinner::new(
      style=@components.SpinnerStyle::Dots,
      message="Network Active",
      color=RGBA::new(0.4, 0.8, 1.0, 1.0)
    ),
    
    loading_bar: @components.LoadingBar::new(
      width=30,
      style=@components.LoadingBarStyle::Bounce,
      color=RGBA::new(0.3, 0.9, 0.3, 1.0)
    ),
    
    cpu_history,
    memory_history,
    history_index: 0
  }
}

fn run_dashboard(renderer : @ffi.Renderer, state : DashboardState) -> Unit {
  renderer.set_use_thread(true)
  renderer.set_background_color(0.02, 0.02, 0.05, 1.0)
  
  let mut running = true
  let mut paused = false
  let mut frame = 0
  let mut update_counter = 0
  
  while running {
    // Handle input
    let event = @ffi.poll_input_event()
    match event {
      @ffi.InputEvent::Key(key) => {
        match key {
          @ffi.KeyEvent::Escape => running = false
          @ffi.KeyEvent::Char(113) => running = false  // 'q'
          @ffi.KeyEvent::Char(114) => {  // 'r' - refresh
            update_dashboard_data(state)
          }
          @ffi.KeyEvent::Char(112) => {  // 'p' - pause
            paused = not(paused)
          }
          _ => ()
        }
      }
      
      @ffi.InputEvent::Resize(new_width, new_height) => {
        renderer.resize(new_width, new_height)
      }
      
      _ => ()
    }
    
    // Update data periodically
    if not(paused) {
      update_counter = update_counter + 1
      if update_counter % 30 == 0 {  // Update every ~0.5 seconds
        update_dashboard_data(state)
      }
      
      // Update animations
      state.network_spinner.update()
      state.loading_bar.update()
      state.uptime_seconds = state.uptime_seconds + 1
    }
    
    // Render dashboard
    render_dashboard(renderer, state, frame, paused)
    
    frame = frame + 1
    @ffi.sleep_ms(16)  // ~60 FPS
  }
}

fn update_dashboard_data(state : DashboardState) -> Unit {
  // Simulate data changes
  let new_cpu = state.cpu_usage + random_delta(0.1)
  state.cpu_usage = if new_cpu < 0.0 { 0.0 } else if new_cpu > 1.0 { 1.0 } else { new_cpu }
  
  let new_mem = state.memory_usage + random_delta(0.05)
  state.memory_usage = if new_mem < 0.0 { 0.0 } else if new_mem > 1.0 { 1.0 } else { new_mem }
  
  let new_disk = state.disk_usage + random_delta(0.02)
  state.disk_usage = if new_disk < 0.0 { 0.0 } else if new_disk > 1.0 { 1.0 } else { new_disk }
  state.network_in = random_value(0.0, 100.0)
  state.network_out = random_value(0.0, 80.0)
  let new_count = state.process_count + random_delta(5.0).to_int()
  state.process_count = if new_count < 100 { 100 } else if new_count > 200 { 200 } else { new_count }
  
  // Update progress bars
  state.cpu_progress.set_value(state.cpu_usage)
  state.memory_progress.set_value(state.memory_usage)
  state.disk_progress.set_value(state.disk_usage)
  
  // Update history
  state.cpu_history[state.history_index] = state.cpu_usage
  state.memory_history[state.history_index] = state.memory_usage
  state.history_index = (state.history_index + 1) % state.cpu_history.length()
}

fn render_dashboard(
  renderer : @ffi.Renderer,
  state : DashboardState,
  frame : Int,
  paused : Bool
) -> Unit {
  let buffer = renderer.get_next_buffer()
  buffer.clear(0.02, 0.02, 0.05, 1.0)
  
  let (width, height) = @ffi.get_terminal_size()
  
  // Draw header
  draw_header(buffer, width, paused)
  
  // Draw system info panel
  draw_system_info(buffer, state, 2_U, 4_U)
  
  // Draw progress bars
  state.cpu_progress.render(buffer, 2_U, 10_U, 40_U, 1_U)
  state.memory_progress.render(buffer, 2_U, 13_U, 40_U, 1_U)
  state.disk_progress.render(buffer, 2_U, 16_U, 40_U, 1_U)
  
  // Draw network panel
  draw_network_panel(buffer, state, 45_U, 4_U)
  
  // Draw process panel
  draw_process_panel(buffer, state, 45_U, 12_U)
  
  // Draw charts
  draw_usage_chart(buffer, state, 2_U, 20_U)
  
  // Draw animations
  state.network_spinner.render(buffer, 45_U, 9_U)
  state.loading_bar.render(buffer, 2_U, height - 3_U)
  
  // Draw footer
  draw_footer(buffer, state, width, height)
  
  renderer.render(force=false)
}

fn draw_header(buffer : @ffi.Buffer, width : UInt, paused : Bool) -> Unit {
  // Draw title bar
  buffer.fill_rect(0_U, 0_U, width, 2_U, 0.1, 0.1, 0.2, 1.0)
  
  let title = "🖥️  System Dashboard"
  let status = if paused { " [PAUSED]" } else { "" }
  
  buffer.draw_text(
    title + status,
    2_U, 0_U,
    fg_r=0.9, fg_g=0.9, fg_b=1.0,
    bold=true
  )
  
  // Draw time
  let time_str = "Uptime: " + format_duration(0)  // Placeholder
  buffer.draw_text(
    time_str,
    width - time_str.length().reinterpret_as_uint() - 2_U, 0_U,
    fg_r=0.7, fg_g=0.7, fg_b=0.8
  )
}

fn draw_system_info(buffer : @ffi.Buffer, state : DashboardState, x : UInt, y : UInt) -> Unit {
  // Draw box
  draw_panel(buffer, x, y, 40_U, 5_U, "System Resources")
  
  // Draw labels
  buffer.draw_text("CPU:", x + 2_U, y + 1_U, fg_r=0.6, fg_g=0.6, fg_b=0.6)
  buffer.draw_text("Memory:", x + 2_U, y + 2_U, fg_r=0.6, fg_g=0.6, fg_b=0.6)
  buffer.draw_text("Disk:", x + 2_U, y + 3_U, fg_r=0.6, fg_g=0.6, fg_b=0.6)
  
  // Draw values
  let cpu_text = format_percentage(state.cpu_usage)
  let mem_text = format_percentage(state.memory_usage)
  let disk_text = format_percentage(state.disk_usage)
  
  buffer.draw_text(cpu_text, x + 12_U, y + 1_U, fg_r=0.9, fg_g=0.9, fg_b=0.9)
  buffer.draw_text(mem_text, x + 12_U, y + 2_U, fg_r=0.9, fg_g=0.9, fg_b=0.9)
  buffer.draw_text(disk_text, x + 12_U, y + 3_U, fg_r=0.9, fg_g=0.9, fg_b=0.9)
}

fn draw_network_panel(buffer : @ffi.Buffer, state : DashboardState, x : UInt, y : UInt) -> Unit {
  draw_panel(buffer, x, y, 30_U, 6_U, "Network")
  
  buffer.draw_text("↓ In:", x + 2_U, y + 1_U, fg_r=0.4, fg_g=0.8, fg_b=0.4)
  buffer.draw_text(
    state.network_in.to_int().to_string() + " KB/s",
    x + 10_U, y + 1_U,
    fg_r=0.9, fg_g=0.9, fg_b=0.9
  )
  
  buffer.draw_text("↑ Out:", x + 2_U, y + 2_U, fg_r=0.8, fg_g=0.4, fg_b=0.4)
  buffer.draw_text(
    state.network_out.to_int().to_string() + " KB/s",
    x + 10_U, y + 2_U,
    fg_r=0.9, fg_g=0.9, fg_b=0.9
  )
}

fn draw_process_panel(buffer : @ffi.Buffer, state : DashboardState, x : UInt, y : UInt) -> Unit {
  draw_panel(buffer, x, y, 30_U, 6_U, "Processes")
  
  buffer.draw_text("Total:", x + 2_U, y + 1_U, fg_r=0.6, fg_g=0.6, fg_b=0.6)
  buffer.draw_text(
    state.process_count.to_string(),
    x + 10_U, y + 1_U,
    fg_r=0.9, fg_g=0.9, fg_b=0.9,
    bold=true
  )
  
  // Show top processes (simulated)
  buffer.draw_text("Top:", x + 2_U, y + 3_U, fg_r=0.6, fg_g=0.6, fg_b=0.6)
  buffer.draw_text("terminal (12%)", x + 8_U, y + 3_U, fg_r=0.8, fg_g=0.8, fg_b=0.8)
  buffer.draw_text("browser (8%)", x + 8_U, y + 4_U, fg_r=0.8, fg_g=0.8, fg_b=0.8)
}

fn draw_usage_chart(buffer : @ffi.Buffer, state : DashboardState, x : UInt, y : UInt) -> Unit {
  draw_panel(buffer, x, y, 60_U, 10_U, "Usage History")
  
  // Draw simple ASCII chart
  let chart_height = 6
  let chart_width = state.cpu_history.length()
  
  // Draw Y axis
  for h = 0; h < chart_height; h = h + 1 {
    let label = (100 - h * 20).to_string() + "%"
    buffer.draw_text(
      label,
      x + 1_U, y + 2_U + h.reinterpret_as_uint(),
      fg_r=0.4, fg_g=0.4, fg_b=0.4
    )
  }
  
  // Draw chart data
  for i = 0; i < chart_width.min(50); i = i + 1 {
    let cpu_val = state.cpu_history[(state.history_index + i) % chart_width]
    let mem_val = state.memory_history[(state.history_index + i) % chart_width]
    
    let cpu_height = (cpu_val * chart_height.to_double()).to_int()
    let mem_height = (mem_val * chart_height.to_double()).to_int()
    
    // Draw CPU bar
    for h = 0; h < cpu_height; h = h + 1 {
      buffer.draw_text(
        "▄",
        x + 7_U + i.reinterpret_as_uint(),
        y + 2_U + (chart_height - 1 - h).reinterpret_as_uint(),
        fg_r=0.2, fg_g=0.8, fg_b=0.4
      )
    }
    
    // Draw memory dot
    if mem_height > 0 {
      buffer.draw_text(
        "●",
        x + 7_U + i.reinterpret_as_uint(),
        y + 2_U + (chart_height - mem_height).reinterpret_as_uint(),
        fg_r=0.8, fg_g=0.6, fg_b=0.2
      )
    }
  }
  
  // Legend
  buffer.draw_text("■ CPU", x + 58_U, y + 2_U, fg_r=0.2, fg_g=0.8, fg_b=0.4)
  buffer.draw_text("● MEM", x + 58_U, y + 3_U, fg_r=0.8, fg_g=0.6, fg_b=0.2)
}

fn draw_footer(buffer : @ffi.Buffer, state : DashboardState, width : UInt, height : UInt) -> Unit {
  buffer.fill_rect(0_U, height - 1_U, width, 1_U, 0.05, 0.05, 0.1, 1.0)
  
  let help = "[r]efresh [p]ause [q]uit"
  buffer.draw_text(
    help,
    2_U, height - 1_U,
    fg_r=0.5, fg_g=0.5, fg_b=0.6
  )
}

fn draw_panel(
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt,
  width : UInt,
  height : UInt,
  title : String
) -> Unit {
  // Draw box border
  let border_chars = FixedArray::make(6, 0_U)
  border_chars[0] = 0x250C_U // ┌
  border_chars[1] = 0x2500_U // ─
  border_chars[2] = 0x2510_U // ┐
  border_chars[3] = 0x2502_U // │
  border_chars[4] = 0x2514_U // └
  border_chars[5] = 0x2518_U // ┘
  
  let border_color = FixedArray::make(4, 0.0)
  border_color[0] = 0.2; border_color[1] = 0.3; border_color[2] = 0.4; border_color[3] = 1.0
  
  let bg_color = FixedArray::make(4, 0.0)
  bg_color[0] = 0.03; bg_color[1] = 0.03; bg_color[2] = 0.06; bg_color[3] = 1.0
  
  buffer.draw_box(
    x.reinterpret_as_int(), y.reinterpret_as_int(),
    width, height,
    border_chars,
    1_U,  // Fill background
    border_color, bg_color,
    title=" " + title + " "
  )
}

// Utility functions
fn random_value(min : Double, max : Double) -> Double {
  // Simple pseudo-random
  min + ((max - min) * 0.5)  // Placeholder
}

fn random_delta(max_delta : Double) -> Double {
  // Random change between -max_delta and +max_delta
  -max_delta + (max_delta * 2.0 * 0.5)  // Placeholder
}

fn format_percentage(value : Double) -> String {
  (value * 100.0).to_int().to_string() + "%"
}

fn format_duration(seconds : Int) -> String {
  let hours = seconds / 3600
  let minutes = (seconds % 3600) / 60
  let secs = seconds % 60
  
  if hours > 0 {
    hours.to_string() + "h " + minutes.to_string() + "m"
  } else if minutes > 0 {
    minutes.to_string() + "m " + secs.to_string() + "s"
  } else {
    secs.to_string() + "s"
  }
}