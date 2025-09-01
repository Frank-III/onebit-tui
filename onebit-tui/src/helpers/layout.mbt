///|
/// Layout helper functions for component composition

/// Create a vertical stack of components
pub fn vstack(children : Array[@core.BaseRenderable]) -> @components.Group {
  let mut group = @components.Group::new("vstack")
  for child in children {
    group = group.add_child(child)
  }
  group
}

/// Create a horizontal stack of components  
pub fn hstack(children : Array[@core.BaseRenderable]) -> @components.Group {
  let mut group = @components.Group::new("hstack")
  for child in children {
    group = group.add_child(child)
  }
  group
}

/// Create a z-axis stack (overlapping components)
pub fn zstack(children : Array[@core.BaseRenderable]) -> @components.Group {
  let mut group = @components.Group::new("zstack")
  for child in children {
    group = group.add_child(child)
  }
  group
}

/// Add padding around a component
pub fn padding(amount : Int, component : @core.BaseRenderable) -> @components.Box {
  let mut box = @components.Box::new("padding-wrapper")
    .with_padding(amount)
    .with_border_style(@core.BorderStyle::None)
  box = box.add_child(component)
  box
}

/// Center a component within its parent
pub fn center(component : @core.BaseRenderable) -> @components.Group {
  let mut group = @components.Group::new("center-wrapper")
  group = group.add_child(component)
  group
}
