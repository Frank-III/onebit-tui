pub(all) struct Tooltip {
  text : String
  mut visible : Bool
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  position : TooltipPosition
  max_width : Int
}

pub(all) enum TooltipPosition {
  Above
  Below
  Left
  Right
}

pub fn Tooltip::new(
  text : String,
  ~position : TooltipPosition = TooltipPosition::Above,
  ~max_width : Int = 40
) -> Tooltip {
  let lines = text.split('\n')
  let mut width = 0
  for line in lines {
    if line.length() > width {
      width = line.length()
    }
  }
  
  // Clamp width to max_width
  if width > max_width {
    width = max_width
  }
  
  // Add padding
  width += 2
  let height = lines.length() + 2 // +2 for border
  
  Tooltip {
    text,
    visible: false,
    x: 0,
    y: 0,
    width,
    height,
    position,
    max_width,
  }
}

pub fn render(self : Tooltip, buffer : Buffer) -> Unit {
  if not(self.visible) {
    return
  }
  
  // Ensure tooltip is within buffer bounds
  let mut draw_x = self.x
  let mut draw_y = self.y
  
  if draw_x + self.width > buffer.width {
    draw_x = buffer.width - self.width
  }
  if draw_x < 0 {
    draw_x = 0
  }
  
  if draw_y + self.height > buffer.height {
    draw_y = buffer.height - self.height
  }
  if draw_y < 0 {
    draw_y = 0
  }
  
  let style = buffer.theme.get_style("tooltip")
  let border_style = buffer.theme.get_style("tooltipBorder")
  
  // Draw tooltip box
  buffer.draw_box(
    draw_x,
    draw_y,
    self.width,
    self.height,
    ~style = BoxStyle::Single,
    ~fg = border_style.fg,
    ~bg = style.bg
  )
  
  // Draw text with word wrapping
  let lines = self.wrap_text(self.text, self.width - 2)
  for i, line in lines {
    if i < self.height - 2 {
      // Clear the line first
      buffer.fill_rect(
        draw_x + 1,
        draw_y + 1 + i,
        self.width - 2,
        1,
        ' ',
        style.fg,
        style.bg
      )
      
      // Draw the text
      buffer.write_string(
        draw_x + 1,
        draw_y + 1 + i,
        line,
        style.fg,
        style.bg
      )
    }
  }
}

fn wrap_text(self : Tooltip, text : String, max_width : Int) -> Array[String] {
  let mut lines = []
  let words = text.split(' ')
  let mut current_line = ""
  
  for word in words {
    if current_line.length() == 0 {
      current_line = word
    } else if current_line.length() + 1 + word.length() <= max_width {
      current_line = current_line + " " + word
    } else {
      lines.push(current_line)
      current_line = word
    }
  }
  
  if current_line.length() > 0 {
    lines.push(current_line)
  }
  
  // Handle lines that are still too long
  let mut wrapped_lines = []
  for line in lines {
    if line.length() <= max_width {
      wrapped_lines.push(line)
    } else {
      // Hard wrap long lines
      let mut i = 0
      while i < line.length() {
        let end = if i + max_width < line.length() { i + max_width } else { line.length() }
        wrapped_lines.push(line.substring(i, end))
        i = end
      }
    }
  }
  
  wrapped_lines
}

pub fn show_at(self : Tooltip, target_x : Int, target_y : Int, target_width : Int, target_height : Int) -> Unit {
  // Calculate position based on tooltip position and target
  match self.position {
    TooltipPosition::Above => {
      self.x = target_x + (target_width - self.width) / 2
      self.y = target_y - self.height
    }
    TooltipPosition::Below => {
      self.x = target_x + (target_width - self.width) / 2
      self.y = target_y + target_height
    }
    TooltipPosition::Left => {
      self.x = target_x - self.width
      self.y = target_y + (target_height - self.height) / 2
    }
    TooltipPosition::Right => {
      self.x = target_x + target_width
      self.y = target_y + (target_height - self.height) / 2
    }
  }
  
  self.visible = true
}

pub fn hide(self : Tooltip) -> Unit {
  self.visible = false
}

pub fn set_text(self : Tooltip, text : String) -> Unit {
  self.text = text
  
  // Recalculate dimensions
  let lines = text.split('\n')
  let mut width = 0
  for line in lines {
    if line.length() > width {
      width = line.length()
    }
  }
  
  if width > self.max_width {
    width = self.max_width
  }
  
  self.width = width + 2
  self.height = lines.length() + 2
}

pub fn is_visible(self : Tooltip) -> Bool {
  self.visible
}