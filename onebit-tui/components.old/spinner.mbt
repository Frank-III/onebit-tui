///| Spinner/Loading Component
///| Various animated loading indicators

pub(all) enum SpinnerStyle {
  Dots
  Line
  Circle
  Square
  Arrow
  BouncingBall
  Pulse
  Wave
  Clock
  Moon
  Runner
  Hamburger
  GrowingBar
  CircleDots
  BoxBounce
  Binary
  Matrix
  Custom(FixedArray[String])
}

pub struct Spinner {
  style : SpinnerStyle
  mut frame : Int
  mut active : Bool
  message : String
  speed : Int  // Frames per animation step
  color : @core.RGBA
  size : SpinnerSize
}

pub enum SpinnerSize {
  Small
  Medium
  Large
}

pub fn Spinner::new(
  style~ : SpinnerStyle = Dots,
  message~ : String = "",
  speed~ : Int = 6,
  color~ : @core.RGBA = @core.RGBA::new(0.5, 0.8, 1.0, 1.0),
  size~ : SpinnerSize = Medium,
  active~ : Bool = true
) -> Spinner {
  Spinner::{
    style,
    frame: 0,
    active,
    message,
    speed,
    color,
    size
  }
}

pub fn Spinner::start(self : Spinner) -> Unit {
  self.active = true
  self.frame = 0
}

pub fn Spinner::stop(self : Spinner) -> Unit {
  self.active = false
}

pub fn Spinner::update(self : Spinner) -> Unit {
  if self.active {
    self.frame = self.frame + 1
  }
}

fn get_spinner_frames(style : SpinnerStyle) -> FixedArray[String] {
  match style {
    Dots => {
      let frames = FixedArray::make(10, "")
      frames[0] = "⠋"; frames[1] = "⠙"; frames[2] = "⠹"
      frames[3] = "⠸"; frames[4] = "⠼"; frames[5] = "⠴"
      frames[6] = "⠦"; frames[7] = "⠧"; frames[8] = "⠇"
      frames[9] = "⠏"
      frames
    }
    
    Line => {
      let frames = FixedArray::make(4, "")
      frames[0] = "-"; frames[1] = "\\"
      frames[2] = "|"; frames[3] = "/"
      frames
    }
    
    Circle => {
      let frames = FixedArray::make(8, "")
      frames[0] = "◐"; frames[1] = "◓"; frames[2] = "◑"; frames[3] = "◒"
      frames[4] = "◐"; frames[5] = "◓"; frames[6] = "◑"; frames[7] = "◒"
      frames
    }
    
    Square => {
      let frames = FixedArray::make(4, "")
      frames[0] = "◰"; frames[1] = "◳"
      frames[2] = "◲"; frames[3] = "◱"
      frames
    }
    
    Arrow => {
      let frames = FixedArray::make(8, "")
      frames[0] = "←"; frames[1] = "↖"; frames[2] = "↑"; frames[3] = "↗"
      frames[4] = "→"; frames[5] = "↘"; frames[6] = "↓"; frames[7] = "↙"
      frames
    }
    
    BouncingBall => {
      let frames = FixedArray::make(10, "")
      frames[0] = "⠁"; frames[1] = "⠂"; frames[2] = "⠄"
      frames[3] = "⡀"; frames[4] = "⢀"; frames[5] = "⠠"
      frames[6] = "⠐"; frames[7] = "⠈"; frames[8] = " "
      frames[9] = " "
      frames
    }
    
    Pulse => {
      let frames = FixedArray::make(4, "")
      frames[0] = "∙"; frames[1] = "●"
      frames[2] = "●"; frames[3] = "∙"
      frames
    }
    
    Wave => {
      let frames = FixedArray::make(10, "")
      frames[0] = "▁"; frames[1] = "▂"; frames[2] = "▃"
      frames[3] = "▄"; frames[4] = "▅"; frames[5] = "▆"
      frames[6] = "▇"; frames[7] = "█"; frames[8] = "▇"
      frames[9] = "▆"
      frames
    }
    
    Clock => {
      let frames = FixedArray::make(12, "")
      frames[0] = "🕐"; frames[1] = "🕑"; frames[2] = "🕒"
      frames[3] = "🕓"; frames[4] = "🕔"; frames[5] = "🕕"
      frames[6] = "🕖"; frames[7] = "🕗"; frames[8] = "🕘"
      frames[9] = "🕙"; frames[10] = "🕚"; frames[11] = "🕛"
      frames
    }
    
    Moon => {
      let frames = FixedArray::make(8, "")
      frames[0] = "🌑"; frames[1] = "🌒"; frames[2] = "🌓"
      frames[3] = "🌔"; frames[4] = "🌕"; frames[5] = "🌖"
      frames[6] = "🌗"; frames[7] = "🌘"
      frames
    }
    
    Runner => {
      let frames = FixedArray::make(2, "")
      frames[0] = "🏃"; frames[1] = "🏃"
      frames
    }
    
    Hamburger => {
      let frames = FixedArray::make(3, "")
      frames[0] = "☰"; frames[1] = "☱"; frames[2] = "☲"
      frames
    }
    
    GrowingBar => {
      let frames = FixedArray::make(8, "")
      frames[0] = "[    ]"; frames[1] = "[=   ]"; frames[2] = "[==  ]"
      frames[3] = "[=== ]"; frames[4] = "[====]"; frames[5] = "[ ===]"
      frames[6] = "[  ==]"; frames[7] = "[   =]"
      frames
    }
    
    CircleDots => {
      let frames = FixedArray::make(8, "")
      frames[0] = "○○○"; frames[1] = "●○○"; frames[2] = "●●○"
      frames[3] = "●●●"; frames[4] = "○●●"; frames[5] = "○○●"
      frames[6] = "○○○"; frames[7] = "○○○"
      frames
    }
    
    BoxBounce => {
      let frames = FixedArray::make(8, "")
      frames[0] = "▖"; frames[1] = "▘"; frames[2] = "▝"
      frames[3] = "▗"; frames[4] = "▖"; frames[5] = "▘"
      frames[6] = "▝"; frames[7] = "▗"
      frames
    }
    
    Binary => {
      let frames = FixedArray::make(8, "")
      frames[0] = "000"; frames[1] = "001"; frames[2] = "010"
      frames[3] = "011"; frames[4] = "100"; frames[5] = "101"
      frames[6] = "110"; frames[7] = "111"
      frames
    }
    
    Matrix => {
      let frames = FixedArray::make(6, "")
      frames[0] = "╱"; frames[1] = "─"; frames[2] = "╲"
      frames[3] = "│"; frames[4] = "╱"; frames[5] = "─"
      frames
    }
    
    Custom(frames) => frames
  }
}

pub fn Spinner::render(
  self : Spinner,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt
) -> Unit {
  if not(self.active) {
    return
  }
  
  let frames = get_spinner_frames(self.style)
  let frame_index = (self.frame / self.speed) % frames.length()
  let spinner_char = frames[frame_index]
  
  // Render based on size
  match self.size {
    Small => {
      buffer.draw_text(
        spinner_char,
        x, y,
        fg_r=self.color.r,
        fg_g=self.color.g,
        fg_b=self.color.b
      )
    }
    
    Medium => {
      // Draw a slightly larger spinner with padding
      buffer.draw_text(
        " " + spinner_char + " ",
        x, y,
        fg_r=self.color.r,
        fg_g=self.color.g,
        fg_b=self.color.b,
        bold=true
      )
    }
    
    Large => {
      // Draw a box around the spinner
      let box_width = 5_U
      let box_height = 3_U
      
      // Draw box background
      buffer.fill_rect(
        x, y, box_width, box_height,
        0.05, 0.05, 0.1, 0.8
      )
      
      // Draw spinner in center
      buffer.draw_text(
        spinner_char,
        x + 2, y + 1,
        fg_r=self.color.r,
        fg_g=self.color.g,
        fg_b=self.color.b,
        bold=true
      )
    }
  }
  
  // Draw message if present
  if self.message.length() > 0 {
    let message_x = match self.size {
      Small => x + 2
      Medium => x + 4  
      Large => x + 6
    }
    
    buffer.draw_text(
      self.message,
      message_x, y,
      fg_r=0.8, fg_g=0.8, fg_b=0.8
    )
  }
}

// Loading Bar - A different take on loading animation
pub struct LoadingBar {
  mut position : Int
  width : UInt
  style : LoadingBarStyle
  mut frame : Int
  mut active : Bool
  color : @core.RGBA
}

pub(all) enum LoadingBarStyle {
  Bounce
  Slide
  Expand
  Rotate
}

pub fn LoadingBar::new(
  width~ : UInt = 20,
  style~ : LoadingBarStyle = Bounce,
  color~ : @core.RGBA = @core.RGBA::new(0.3, 0.7, 1.0, 1.0),
  active~ : Bool = true
) -> LoadingBar {
  LoadingBar::{
    position: 0,
    width,
    style,
    frame: 0,
    active,
    color
  }
}

pub fn LoadingBar::update(self : LoadingBar) -> Unit {
  if not(self.active) {
    return
  }
  
  self.frame = self.frame + 1
  
  match self.style {
    Bounce => {
      // Bounce back and forth
      let cycle = self.frame % (self.width.reinterpret_as_int() * 2)
      if cycle < self.width.reinterpret_as_int() {
        self.position = cycle
      } else {
        self.position = self.width.reinterpret_as_int() * 2 - cycle
      }
    }
    
    Slide => {
      // Slide from left to right and wrap
      self.position = self.frame % (self.width.reinterpret_as_int() + 5)
    }
    
    Expand => {
      // Expand and contract from center
      let cycle = self.frame % 20
      if cycle < 10 {
        self.position = cycle
      } else {
        self.position = 20 - cycle
      }
    }
    
    Rotate => {
      // Rotate through positions
      self.position = (self.frame / 3) % self.width.reinterpret_as_int()
    }
  }
}

pub fn LoadingBar::render(
  self : LoadingBar,
  buffer : @ffi.Buffer,
  x : UInt,
  y : UInt
) -> Unit {
  if not(self.active) {
    return
  }
  
  // Draw background track
  for i = 0_U; i < self.width; i = i + 1 {
    buffer.draw_text(
      "─",
      x + i, y,
      fg_r=0.2, fg_g=0.2, fg_b=0.2
    )
  }
  
  match self.style {
    Bounce | Slide => {
      // Draw the moving indicator
      if self.position >= 0 && self.position < self.width.reinterpret_as_int() {
        let indicator_width = 3
        for i = 0; i < indicator_width; i = i + 1 {
          let pos = self.position + i
          if pos >= 0 && pos < self.width.reinterpret_as_int() {
            let intensity = if i == 1 { "█" } else { "▓" }
            buffer.draw_text(
              intensity,
              x + pos.reinterpret_as_uint(), y,
              fg_r=self.color.r,
              fg_g=self.color.g,
              fg_b=self.color.b
            )
          }
        }
      }
    }
    
    Expand => {
      // Draw expanding/contracting bar from center
      let center = self.width.reinterpret_as_int() / 2
      let half_width = self.position
      
      for i = -half_width; i <= half_width; i = i + 1 {
        let pos = center + i
        if pos >= 0 && pos < self.width.reinterpret_as_int() {
          buffer.draw_text(
            "█",
            x + pos.reinterpret_as_uint(), y,
            fg_r=self.color.r,
            fg_g=self.color.g,
            fg_b=self.color.b
          )
        }
      }
    }
    
    Rotate => {
      // Draw rotating segments
      let segment_chars = ["▏", "▎", "▍", "▌", "▋", "▊", "▉", "█"]
      for i = 0_U; i < self.width; i = i + 1 {
        let distance = (i.reinterpret_as_int() - self.position).abs()
        let intensity = (7 - distance.min(7)).max(0)
        
        if intensity > 0 {
          buffer.draw_text(
            segment_chars[intensity],
            x + i, y,
            fg_r=self.color.r * (intensity.to_double() / 7.0),
            fg_g=self.color.g * (intensity.to_double() / 7.0),
            fg_b=self.color.b * (intensity.to_double() / 7.0)
          )
        }
      }
    }
  }
}