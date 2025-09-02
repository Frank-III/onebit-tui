///| Base renderable class that all UI components extend from
///| Mirrors the TypeScript Renderable architecture

/// Base struct that all components will contain
pub(all) struct BaseRenderable {
  id : String
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  mut visible : Bool
  mut children : Array[BaseRenderable]
  mut parent : BaseRenderable?
  mut z_index : Int
  mut needs_layout_update : Bool
  mut background_color : RGBA
  mut foreground_color : RGBA
  // Function pointer for rendering this specific component
  mut render_fn : ((BaseRenderable, TerminalBuffer) -> Unit)?
}

pub fn BaseRenderable::new(id : String) -> BaseRenderable {
  {
    id,
    x: 0,
    y: 0,
    width: 10,
    height: 10,
    visible: true,
    children: [],
    parent: None,
    z_index: 0,
    needs_layout_update: true,
    background_color: RGBA::black(),
    foreground_color: RGBA::white(),
    render_fn: None
  }
}

/// Add a child renderable
pub fn BaseRenderable::add_child(self : BaseRenderable, child : BaseRenderable) -> Unit {
  child.parent = Some(self)
  self.children.push(child)
  self.needs_layout_update = true
}

/// Remove a child by id
pub fn BaseRenderable::remove_child(self : BaseRenderable, child_id : String) -> Unit {
  let new_children = []
  for child in self.children {
    if child.id != child_id {
      new_children.push(child)
    } else {
      child.parent = None
    }
  }
  self.children = new_children
  self.needs_layout_update = true
}

/// Layout properties that can be mixed in
pub struct LayoutProps {
  mut flex_grow : Float
  mut flex_shrink : Float  
  mut flex_basis : Float?
  mut padding : Int
  mut margin : Int
  mut position : PositionType
}

pub enum PositionType {
  Relative
  Absolute
}

pub fn LayoutProps::default() -> LayoutProps {
  {
    flex_grow: 0.0,
    flex_shrink: 0.0,
    flex_basis: None,
    padding: 0,
    margin: 0,
    position: PositionType::Relative
  }
}

/// Sort children by z-index
pub fn BaseRenderable::sort_children_by_z_index(self : BaseRenderable) -> Unit {
  // Simple bubble sort for now
  let len = self.children.length()
  for i = 0; i < len - 1; i = i + 1 {
    for j = 0; j < len - i - 1; j = j + 1 {
      if self.children[j].z_index > self.children[j + 1].z_index {
        let temp = self.children[j]
        self.children[j] = self.children[j + 1]
        self.children[j + 1] = temp
      }
    }
  }
}

/// Find a child by id
pub fn BaseRenderable::find_child(self : BaseRenderable, id : String) -> BaseRenderable? {
  for child in self.children {
    if child.id == id {
      return Some(child)
    }
  }
  None
}

/// Get absolute position (accounting for parent positions)
pub fn BaseRenderable::absolute_x(self : BaseRenderable) -> Int {
  match self.parent {
    Some(parent) => parent.absolute_x() + self.x
    None => self.x
  }
}

pub fn BaseRenderable::absolute_y(self : BaseRenderable) -> Int {
  match self.parent {
    Some(parent) => parent.absolute_y() + self.y
    None => self.y
  }
}

/// Main render method that all components use
pub fn BaseRenderable::render(self : BaseRenderable, buffer : TerminalBuffer) -> Unit {
  if not(self.visible) {
    return
  }
  
  // Render self using the component-specific render function
  match self.render_fn {
    Some(render_fn) => render_fn(self, buffer)
    None => ()
  }
  
  // Sort children by z-index before rendering
  self.sort_children_by_z_index()
  
  // Render children
  for child in self.children {
    child.render(buffer)
  }
}

/// Set the component-specific render function
pub fn BaseRenderable::set_render_fn(self : BaseRenderable, render_fn : (BaseRenderable, TerminalBuffer) -> Unit) -> Unit {
  self.render_fn = Some(render_fn)
}

// Accessor methods for helpers
pub fn BaseRenderable::set_x(self : BaseRenderable, x : Int) -> Unit {
  self.x = x
}

pub fn BaseRenderable::set_y(self : BaseRenderable, y : Int) -> Unit {
  self.y = y
}

pub fn BaseRenderable::set_z_index(self : BaseRenderable, z : Int) -> Unit {
  self.z_index = z
}

pub fn BaseRenderable::width(self : BaseRenderable) -> Int {
  self.width
}

pub fn BaseRenderable::height(self : BaseRenderable) -> Int {
  self.height
}