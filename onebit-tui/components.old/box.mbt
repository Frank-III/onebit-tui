///| Box component - a container with border and optional title

pub struct Box {
  mut border : Bool
  mut title : String?
  mut padding : Int
  mut background : @core.RGBA
  mut border_color : @core.RGBA
}

pub fn Box::new() -> Box {
  {
    border: true,
    title: None,
    padding: 0,
    background: @core.RGBA::new(0.0, 0.0, 0.0, 1.0),
    border_color: @core.RGBA::new(1.0, 1.0, 1.0, 1.0)
  }
}

pub fn Box::with_title(self : Box, title : String) -> Box {
  self.title = Some(title)
  self
}

pub fn Box::with_border(self : Box, border : Bool) -> Box {
  self.border = border
  self
}

pub fn Box::with_padding(self : Box, padding : Int) -> Box {
  self.padding = padding
  self
}