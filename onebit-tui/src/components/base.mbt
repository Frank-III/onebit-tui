///| Base component system for OneBit-TUI

///|
/// Simple, working implementation

// Core component trait - simplified for now
pub trait Component {
  render(Self, @core.App, Int, Int) -> Unit
  width(Self) -> Int
  height(Self) -> Int
}

// Box component

///|
pub struct Box {
  width : Int
  height : Int
  title : String
  color : @core.Color
}

///|
pub fn Box::new(width : Int, height : Int) -> Box {
  { width, height, title: "", color: @core.Color::Gray }
}

///|
pub fn Box::with_title(self : Box, title : String) -> Box {
  { ..self, title, }
}

///|
pub fn Box::with_color(self : Box, color : @core.Color) -> Box {
  { ..self, color, }
}

///|
impl Component for Box with render(self, app, x, y) {
  // Draw the box background
  app.draw_rect(x, y, self.width, self.height, self.color)

  // Draw title if present
  if self.title.length() > 0 {
    app.draw_text(self.title, x + 2, y, @core.Color::White)
  }
}

///|
impl Component for Box with width(self) {
  self.width
}

///|
impl Component for Box with height(self) {
  self.height
}

// Text component

///|
pub struct Text {
  content : String
  color : @core.Color
}

///|
pub fn Text::new(content : String) -> Text {
  { content, color: @core.Color::White }
}

///|
pub fn Text::with_color(self : Text, color : @core.Color) -> Text {
  { ..self, color, }
}

///|
impl Component for Text with render(self, app, x, y) {
  app.draw_text(self.content, x, y, self.color)
}

///|
impl Component for Text with width(self) {
  self.content.length()
}

///|
impl Component for Text with height(self) {
  1
}

// Container that can hold multiple components

///|
pub struct Container {
  mut children : Array[(Int, Int, &Component)]
}

///|
pub fn Container::new() -> Container {
  { children: [] }
}

///|
pub fn Container::add(
  self : Container,
  x : Int,
  y : Int,
  component : &Component,
) -> Unit {
  self.children.push((x, y, component))
}

///|
pub fn Container::render(self : Container, app : @core.App) -> Unit {
  for i = 0; i < self.children.length(); i = i + 1 {
    let (x, y, component) = self.children[i]
    component.render(app, x, y)
  }
}
