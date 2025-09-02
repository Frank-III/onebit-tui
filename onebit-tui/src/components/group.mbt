///|
/// Group component - an invisible container like React Fragment

///|
/// Group is an invisible container that only renders its children
/// It has no visual representation of its own
pub struct Group {
  mut base : @core.BaseRenderable
}

///|
pub fn Group::new(id : String) -> Group {
  {
    base: @core.BaseRenderable::new(id),
  }
}

///|
/// Get the base renderable
pub fn Group::as_renderable(self : Group) -> @core.BaseRenderable {
  // Group has no custom render function - it just renders children
  self.base
}

/// Add a child to this group's base renderable
pub fn Group::add_child(self : Group, child : @core.BaseRenderable) -> Group {
  self.base.add_child(child)
  self
}

/// Helper to set dimensions
pub fn Group::with_dimensions(self : Group, x : Int, y : Int, width : Int, height : Int) -> Group {
  { ..self, base: { ..self.base, x, y, width, height } }
}