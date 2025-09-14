///| Traits for UI builders to provide a clean, consistent API

/// Trait for components that support flexbox properties
pub trait FlexItem {
  flex_grow(Self, Float) -> Self
  flex(Self, Float) -> Self
  flex_shrink(Self, Float) -> Self
}

/// Trait for components that can have dimensions
pub trait Sized {
  width(Self, Float) -> Self
  height(Self, Float) -> Self
  min_width(Self, Float) -> Self
  min_height(Self, Float) -> Self
}

/// Trait for components that can have borders
pub trait Bordered {
  border(Self, Bool) -> Self
  border_style(Self, BorderStyle) -> Self
  border_color(Self, RGBA) -> Self
}

/// Trait for components that can have padding/margin
pub trait Spaced {
  padding(Self, Float) -> Self
  margin(Self, Float) -> Self
  gap(Self, Float) -> Self
}

/// Trait for components that can be styled
pub trait Styled {
  background(Self, RGBA) -> Self
  foreground(Self, RGBA) -> Self
}

/// Trait for components that can be aligned
pub trait Aligned {
  align_items(Self, @types.Align) -> Self
  justify_content(Self, @types.Justify) -> Self
  align_self(Self, @types.Align) -> Self
}

/// Trait for components that have a title
pub trait Titled {
  title(Self, String) -> Self
}

/// Trait for buildable components
pub trait Buildable {
  build(Self) -> UIBuilder
}

/// Trait for components with children
pub trait Container {
  child(Self, UIBuilder) -> Self
  children(Self, Array[UIBuilder]) -> Self
}

// Now implement these traits for our builders

impl FlexItem for BoxBuilder with flex_grow(self, value) {
  self.yoga_node.set_flex_grow(value)
  self
}

impl FlexItem for BoxBuilder with flex(self, value) {
  self.yoga_node.set_flex(value)
  self
}

impl FlexItem for BoxBuilder with flex_shrink(self, value) {
  self.yoga_node.set_flex_shrink(value)
  self
}

impl Sized for BoxBuilder with width(self, value) {
  self.yoga_node.set_width(@types.Value::point(value))
  self
}

impl Sized for BoxBuilder with height(self, value) {
  self.yoga_node.set_height(@types.Value::point(value))
  self
}

impl Sized for BoxBuilder with min_width(self, value) {
  // TODO: set_min_width not implemented - self.yoga_node.set_min_width(value)
  self
}

impl Sized for BoxBuilder with min_height(self, value) {
  // TODO: set_min_height not implemented - self.yoga_node.set_min_height(value)
  self
}

impl Bordered for BoxBuilder with border(self, enabled) {
  self.border = enabled
  self
}

impl Bordered for BoxBuilder with border_style(self, style) {
  self.border = true
  // TODO: border_style field not implemented
  self
}

impl Bordered for BoxBuilder with border_color(self, color) {
  self.border = true
  self.border_color = Some(color)
  self
}

impl Spaced for BoxBuilder with padding(self, value) {
  self.padding = value
  self.yoga_node.set_padding(@types.Edge::All, @types.Value::point(value))
  self
}

impl Spaced for BoxBuilder with margin(self, value) {
  // TODO: margin field not implemented
  self.yoga_node.set_margin(@types.Edge::All, @types.Value::point(value))
  self
}

impl Spaced for BoxBuilder with gap(self, value) {
  // TODO: set_gap not implemented - self.yoga_node.set_gap(@types.Gutter::All, value)
  self
}

impl Styled for BoxBuilder with background(self, color) {
  self.background = Some(color)
  self
}

impl Styled for BoxBuilder with foreground(self, color) {
  // BoxBuilder doesn't have foreground, but we can ignore
  self
}

impl Aligned for BoxBuilder with align_items(self, align) {
  self.yoga_node.set_align_items(align)
  self
}

impl Aligned for BoxBuilder with justify_content(self, justify) {
  self.yoga_node.set_justify_content(justify)
  self
}

impl Aligned for BoxBuilder with align_self(self, align) {
  self.yoga_node.set_align_self(align)
  self
}

impl Titled for BoxBuilder with title(self, text) {
  self.title = Some(text)
  self
}

impl Container for BoxBuilder with child(self, child) {
  self.yoga_node.add_child(child.yoga_node)
  self.children.push(child)
  self
}

impl Container for BoxBuilder with children(self, children) {
  for i = 0; i < children.length(); i = i + 1 {
    self.yoga_node.add_child(children[i].yoga_node)
    self.children.push(children[i])
  }
  self
}

// Implement for ListBuilder
impl FlexItem for ListBuilder with flex_grow(self, value) {
  self.yoga_node.set_flex_grow(value)
  self
}

impl FlexItem for ListBuilder with flex(self, value) {
  self.yoga_node.set_flex(value)
  self
}

impl FlexItem for ListBuilder with flex_shrink(self, value) {
  self.yoga_node.set_flex_shrink(value)
  self
}

impl Sized for ListBuilder with width(self, value) {
  self.yoga_node.set_width(@types.Value::point(value))
  self
}

impl Sized for ListBuilder with height(self, value) {
  self.yoga_node.set_height(@types.Value::point(value))
  self
}

impl Sized for ListBuilder with min_width(self, value) {
  // TODO: set_min_width not implemented - self.yoga_node.set_min_width(value)
  self
}

impl Sized for ListBuilder with min_height(self, value) {
  // TODO: set_min_height not implemented - self.yoga_node.set_min_height(value)
  self
}

impl Bordered for ListBuilder with border(self, enabled) {
  self.border = enabled
  self
}

impl Bordered for ListBuilder with border_style(self, style) {
  self.border = true
  // TODO: border_style field not implemented
  self
}

impl Bordered for ListBuilder with border_color(self, color) {
  self.border = true
  // ListBuilder doesn't have border_color field, would need to add
  self
}

impl Titled for ListBuilder with title(self, text) {
  self.title = Some(text)
  self
}

// Implement for SelectBuilder
impl FlexItem for SelectBuilder with flex_grow(self, value) {
  self.yoga_node.set_flex_grow(value)
  self
}

impl FlexItem for SelectBuilder with flex(self, value) {
  self.yoga_node.set_flex(value)
  self
}

impl FlexItem for SelectBuilder with flex_shrink(self, value) {
  self.yoga_node.set_flex_shrink(value)
  self
}

impl Sized for SelectBuilder with height(self, value) {
  self.yoga_node.set_height(@types.Value::point(value))
  self
}

impl Sized for SelectBuilder with width(self, value) {
  self.yoga_node.set_width(@types.Value::point(value))
  self
}

impl Sized for SelectBuilder with min_width(self, value) {
  // TODO: set_min_width not implemented - self.yoga_node.set_min_width(value)
  self
}

impl Sized for SelectBuilder with min_height(self, value) {
  // TODO: set_min_height not implemented - self.yoga_node.set_min_height(value)
  self
}

impl Bordered for SelectBuilder with border(self, enabled) {
  self.border = enabled
  self
}

impl Bordered for SelectBuilder with border_style(self, style) {
  self.border = true
  // Would need to add border_style field to SelectBuilder
  self
}

impl Bordered for SelectBuilder with border_color(self, color) {
  self.border = true
  // Would need to add border_color field to SelectBuilder
  self
}