///| ProgressBar Component
///| Displays progress with customizable styles and animations

pub(all) enum ProgressBarStyle {
  Solid
  Gradient
  Segmented(Int)  // Number of segments
  Dots
  Spinner
}

pub enum ProgressBarDirection {
  LeftToRight
  RightToLeft
  TopToBottom
  BottomToTop
}

pub struct ProgressBar {
  mut value : Double  // 0.0 to 1.0
  mut min_value : Double
  mut max_value : Double
  style : ProgressBarStyle
  direction : ProgressBarDirection
  show_percentage : Bool
  show_value : Bool
  label : String
  width : UInt
  height : UInt
  
  // Colors
  bar_color : @core.RGBA
  background_color : @core.RGBA
  text_color : @core.RGBA
  border_color : @core.RGBA?
  
  // Animation
  mut animated : Bool
  mut animation_frame : Int
  
  // Custom characters
  filled_char : UInt
  empty_char : UInt
  partial_chars : FixedArray[UInt]  // For smooth progress
}

pub fn ProgressBar::new(
  value~ : Double = 0.0,
  min_value~ : Double = 0.0,
  max_value~ : Double = 1.0,
  style~ : ProgressBarStyle = Solid,
  direction~ : ProgressBarDirection = LeftToRight,
  show_percentage~ : Bool = true,
  show_value~ : Bool = false,
  label~ : String = "",
  bar_color~ : @core.RGBA = @core.RGBA::new(0.2, 0.8, 0.2, 1.0),
  background_color~ : @core.RGBA = @core.RGBA::new(0.1, 0.1, 0.1, 1.0),
  text_color~ : @core.RGBA = @core.RGBA::new(0.9, 0.9, 0.9, 1.0),
  border_color~ : @core.RGBA? = None,
  animated~ : Bool = false
) -> ProgressBar {
  // Create partial fill characters for smooth progress
  let partial_chars = FixedArray::make(8, 0_U)
  partial_chars[0] = 0x258F_U  // ▏
  partial_chars[1] = 0x258E_U  // ▎
  partial_chars[2] = 0x258D_U  // ▍
  partial_chars[3] = 0x258C_U  // ▌
  partial_chars[4] = 0x258B_U  // ▋
  partial_chars[5] = 0x258A_U  // ▊
  partial_chars[6] = 0x2589_U  // ▉
  partial_chars[7] = 0x2588_U  // █
  
  ProgressBar::{
    value: if value < min_value { min_value } else if value > max_value { max_value } else { value },
    min_value,
    max_value,
    style,
    direction,
    show_percentage,
    show_value,
    label,
    width: 20,
    height: 1,
    bar_color,
    background_color,
    text_color,
    border_color,
    animated,
    animation_frame: 0,
    filled_char: 0x2588_U,  // █
    empty_char: 0x2591_U,   // ░
    partial_chars
  }
}

pub fn ProgressBar::set_value(self : ProgressBar, value : Double) -> Unit {
  self.value = if value < self.min_value { self.min_value } else if value > self.max_value { self.max_value } else { value }
}

pub fn ProgressBar::increment(self : ProgressBar, amount : Double) -> Unit {
  self.set_value(self.value + amount)
}

pub fn ProgressBar::get_percentage(self : ProgressBar) -> Double {
  if self.max_value <= self.min_value {
    return 0.0
  }
  (self.value - self.min_value) / (self.max_value - self.min_value)
}

pub fn ProgressBar::update_animation(self : ProgressBar) -> Unit {
  if self.animated {
    self.animation_frame = (self.animation_frame + 1) % 60
  }
}

pub fn ProgressBar::render(
  self : ProgressBar,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt,
  width : UInt,
  height : UInt
) -> Unit {
  let actual_width = if width > 0 { width } else { self.width }
  let actual_height = if height > 0 { height } else { self.height }
  
  // Update animation
  self.update_animation()
  
  // Calculate progress
  let percentage = self.get_percentage()
  
  // Render based on direction
  match self.direction {
    LeftToRight => self.render_horizontal(buffer, x, y, actual_width, actual_height, percentage)
    RightToLeft => self.render_horizontal_reverse(buffer, x, y, actual_width, actual_height, percentage)
    TopToBottom => self.render_vertical(buffer, x, y, actual_width, actual_height, percentage)
    BottomToTop => self.render_vertical_reverse(buffer, x, y, actual_width, actual_height, percentage)
  }
  
  // Render label if present
  if self.label.length() > 0 {
    buffer.draw_text(
      self.label,
      x, y - 1,
      fg_r=self.text_color.r,
      fg_g=self.text_color.g,
      fg_b=self.text_color.b
    )
  }
  
  // Render percentage or value
  if self.show_percentage || self.show_value {
    let text = if self.show_percentage {
      (percentage * 100.0).to_int().to_string() + "%"
    } else {
      self.value.to_int().to_string() + "/" + self.max_value.to_int().to_string()
    }
    
    // Center the text
    let text_x = x + (actual_width - text.length().reinterpret_as_uint()) / 2
    buffer.draw_text(
      text,
      text_x, y,
      fg_r=self.text_color.r,
      fg_g=self.text_color.g,
      fg_b=self.text_color.b,
      bold=true
    )
  }
}

fn render_horizontal(
  self : ProgressBar,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt,
  width : UInt,
  height : UInt,
  percentage : Double
) -> Unit {
  // Draw background
  buffer.fill_rect(
    x, y, width, height,
    self.background_color.r,
    self.background_color.g,
    self.background_color.b,
    self.background_color.a
  )
  
  match self.style {
    Solid => {
      // Calculate filled width
      let filled_width = (width.reinterpret_as_int().to_double() * percentage).to_int()
      let partial_width = ((width.reinterpret_as_int().to_double() * percentage) - filled_width.to_double()) * 8.0
      
      // Draw filled portion
      for i = 0; i < filled_width; i = i + 1 {
        buffer.draw_text(
          self.filled_char.reinterpret_as_int().unsafe_to_char().to_string(),
          x + i.reinterpret_as_uint(), y,
          fg_r=self.bar_color.r,
          fg_g=self.bar_color.g,
          fg_b=self.bar_color.b
        )
      }
      
      // Draw partial character for smooth progress
      if filled_width < width.reinterpret_as_int() && partial_width.to_int() > 0 {
        let partial_idx = if partial_width.to_int() > 7 { 7 } else { partial_width.to_int() }
        buffer.draw_text(
          self.partial_chars[partial_idx].reinterpret_as_int().unsafe_to_char().to_string(),
          x + filled_width.reinterpret_as_uint(), y,
          fg_r=self.bar_color.r,
          fg_g=self.bar_color.g,
          fg_b=self.bar_color.b
        )
      }
    }
    
    Gradient => {
      // Gradient from dark to bright
      let filled_width = (width.reinterpret_as_int().to_double() * percentage).to_int()
      
      for i = 0; i < filled_width; i = i + 1 {
        let gradient_factor = i.to_double() / width.reinterpret_as_int().to_double()
        let r = self.bar_color.r * (0.5 + gradient_factor * 0.5)
        let g = self.bar_color.g * (0.5 + gradient_factor * 0.5)
        let b = self.bar_color.b * (0.5 + gradient_factor * 0.5)
        
        buffer.draw_text(
          self.filled_char.reinterpret_as_int().unsafe_to_char().to_string(),
          x + i.reinterpret_as_uint(), y,
          fg_r=r, fg_g=g, fg_b=b
        )
      }
    }
    
    Segmented(segments) => {
      // Draw segmented progress bar
      let segment_width = width.reinterpret_as_int().to_double() / segments.to_double()
      let filled_segments = (percentage * segments.to_double()).to_int()
      
      for seg = 0; seg < segments; seg = seg + 1 {
        let seg_x = x + (seg.to_double() * segment_width).to_int().reinterpret_as_uint()
        let seg_w = segment_width.to_int().reinterpret_as_uint()
        
        if seg < filled_segments {
          // Filled segment
          for i = 0_U; i < seg_w; i = i + 1 {
            buffer.draw_text(
              self.filled_char.reinterpret_as_int().unsafe_to_char().to_string(),
              seg_x + i, y,
              fg_r=self.bar_color.r,
              fg_g=self.bar_color.g,
              fg_b=self.bar_color.b
            )
          }
        }
        
        // Add separator
        if seg < segments - 1 {
          buffer.draw_text(
            "│",
            seg_x + seg_w, y,
            fg_r=0.3, fg_g=0.3, fg_b=0.3
          )
        }
      }
    }
    
    Dots => {
      // Animated dots style
      let filled_width = (width.reinterpret_as_int().to_double() * percentage).to_int()
      let dot_chars = ["⣾", "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽"]
      let dot_idx = self.animation_frame / 8 % 8
      
      for i = 0; i < filled_width; i = i + 1 {
        let char = if i == filled_width - 1 && self.animated {
          dot_chars[dot_idx]
        } else {
          "●"
        }
        
        buffer.draw_text(
          char,
          x + i.reinterpret_as_uint(), y,
          fg_r=self.bar_color.r,
          fg_g=self.bar_color.g,
          fg_b=self.bar_color.b
        )
      }
    }
    
    Spinner => {
      // Spinner animation (for indeterminate progress)
      let spinner_chars = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
      let spinner_idx = self.animation_frame / 6 % 10
      let pos = if self.animated {
        ((self.animation_frame.to_double() / 2.0) % width.reinterpret_as_int().to_double()).to_int()
      } else {
        (width.reinterpret_as_int().to_double() * percentage).to_int()
      }
      
      buffer.draw_text(
        spinner_chars[spinner_idx],
        x + pos.reinterpret_as_uint(), y,
        fg_r=self.bar_color.r,
        fg_g=self.bar_color.g,
        fg_b=self.bar_color.b,
        bold=true
      )
    }
  }
  
  // Draw border if specified
  match self.border_color {
    Some(color) => {
      // Draw simple border characters
      buffer.draw_text("[", x - 1, y, fg_r=color.r, fg_g=color.g, fg_b=color.b)
      buffer.draw_text("]", x + width, y, fg_r=color.r, fg_g=color.g, fg_b=color.b)
    }
    None => ()
  }
}

fn render_horizontal_reverse(
  self : ProgressBar,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt,
  width : UInt,
  height : UInt,
  percentage : Double
) -> Unit {
  // Similar to horizontal but filled from right to left
  // TODO: Implement reverse rendering
  self.render_horizontal(buffer, x, y, width, height, percentage)
}

fn render_vertical(
  self : ProgressBar,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt,
  width : UInt,
  height : UInt,
  percentage : Double
) -> Unit {
  // Vertical progress bar
  let filled_height = (height.reinterpret_as_int().to_double() * percentage).to_int()
  
  for h = 0; h < height.reinterpret_as_int(); h = h + 1 {
    let current_y = y + height - 1 - h.reinterpret_as_uint()
    
    if h < filled_height {
      // Filled portion
      for w = 0_U; w < width; w = w + 1 {
        buffer.draw_text(
          self.filled_char.reinterpret_as_int().unsafe_to_char().to_string(),
          x + w, current_y,
          fg_r=self.bar_color.r,
          fg_g=self.bar_color.g,
          fg_b=self.bar_color.b
        )
      }
    } else {
      // Empty portion
      for w = 0_U; w < width; w = w + 1 {
        buffer.draw_text(
          self.empty_char.reinterpret_as_int().unsafe_to_char().to_string(),
          x + w, current_y,
          fg_r=self.background_color.r,
          fg_g=self.background_color.g,
          fg_b=self.background_color.b
        )
      }
    }
  }
}

fn render_vertical_reverse(
  self : ProgressBar,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt,
  width : UInt,
  height : UInt,
  percentage : Double
) -> Unit {
  // Similar to vertical but filled from top to bottom
  // TODO: Implement reverse vertical rendering
  self.render_vertical(buffer, x, y, width, height, percentage)
}