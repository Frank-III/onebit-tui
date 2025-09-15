///| Core view system for OneBit-TUI using FFI exclusively
///| This replaces the old buffer-based approach

/// Core rendering context with FFI buffer
pub struct FFIRenderContext {
  buffer : @ffi.Buffer
  bounds : Rect
}

/// Render any view directly to FFI
pub fn View::render_ffi(self : View, ctx : FFIRenderContext) -> Unit {
  match self {
    Box(v) => v.render_ffi(ctx)
    Text(v) => v.render_ffi(ctx)
    Group(v) => v.render_ffi(ctx)
    VStack(v) => v.render_ffi(ctx)
    HStack(v) => v.render_ffi(ctx)
    ZStack(v) => v.render_ffi(ctx)
    Spacer(v) => v.render_ffi(ctx)
    Padding(v) => v.render_ffi(ctx)
    Interact(v) => v.render_ffi(ctx)
  }
}

/// Box rendering directly to FFI
pub fn BoxView::render_ffi(self : BoxView, ctx : FFIRenderContext) -> Unit {
  let x = ctx.bounds.x
  let y = ctx.bounds.y
  let width = ctx.bounds.width
  let height = ctx.bounds.height
  
  // Fill background if not black
  if self.background != RGBA::black() {
    ctx.buffer.fill_rect(
      x.reinterpret_as_uint(), 
      y.reinterpret_as_uint(), 
      width.reinterpret_as_uint(), 
      height.reinterpret_as_uint(),
      self.background.r,
      self.background.g,
      self.background.b,
      self.background.a
    )
  }
  
  // Draw border
  if self.border != BorderStyle::None {
    self.draw_border_ffi(ctx)
  }
  
  // Compute inner area excluding border and title (Yoga will handle padding)
  let border_width = if self.border == BorderStyle::None { 0 } else { 1 }
  let title_height = match self.title {
    Some(_) => 1
    None => 0
  }
  let inner_x = x + border_width
  let inner_y = y + border_width + title_height
  let inner_w = width - border_width * 2
  let inner_h = height - border_width * 2 - title_height

  // If no children, nothing more to draw
  if self.children.length() == 0 { return }

  // Yoga layout for children inside the box with padding
  let root = @wrapper.Node::new()
  root.set_flex_direction(@types.FlexDirection::Column)
  root.set_width_points(inner_w.to_double().to_float())
  root.set_height_points(inner_h.to_double().to_float())
  // Padding inside the box
  root.set_padding_all(@types.Value::point(self.padding.to_double().to_float()))

  for i = 0; i < self.children.length(); i = i + 1 {
    let n = @wrapper.Node::new()
    // Default: let content grow equally
    n.set_flex_grow(1.0)
    root.add_child(n)
  }

  root.calculate_layout(inner_w.to_double().to_float(), inner_h.to_double().to_float(), @types.Direction::LTR)

  // Render each child in computed bounds (offset by inner origin)
  for i = 0; i < self.children.length(); i = i + 1 {
    match root.get_child(i) {
      Some(child_node) => {
        let left = child_node.layout_left().to_double().to_int()
        let top = child_node.layout_top().to_double().to_int()
        let w = child_node.layout_width().to_double().to_int()
        let h = child_node.layout_height().to_double().to_int()
        let cb = Rect::new(inner_x + left, inner_y + top, w, h)
        self.children[i].render_ffi(FFIRenderContext::{ buffer: ctx.buffer, bounds: cb })
      }
      None => ()
    }
  }
}

fn BoxView::draw_border_ffi(self : BoxView, ctx : FFIRenderContext) -> Unit {
  let chars = border_chars(self.border)
  let x = ctx.bounds.x
  let y = ctx.bounds.y
  let width = ctx.bounds.width
  let height = ctx.bounds.height
  
  // Helper to draw a single character
  let draw_char = fn(x : Int, y : Int, ch : Char) {
    ctx.buffer.draw_text(
      ch.to_string(),
      x.reinterpret_as_uint(),
      y.reinterpret_as_uint(),
      fg_r=self.border_color.r,
      fg_g=self.border_color.g,
      fg_b=self.border_color.b,
      bg_r=Some(self.background.r),
      bg_g=Some(self.background.g),
      bg_b=Some(self.background.b)
    )
  }
  
  // Corners
  draw_char(x, y, chars.top_left)
  draw_char(x + width - 1, y, chars.top_right)
  draw_char(x, y + height - 1, chars.bottom_left)
  draw_char(x + width - 1, y + height - 1, chars.bottom_right)
  
  // Horizontal lines
  for i = 1; i < width - 1; i = i + 1 {
    draw_char(x + i, y, chars.horizontal)
    draw_char(x + i, y + height - 1, chars.horizontal)
  }
  
  // Vertical lines
  for i = 1; i < height - 1; i = i + 1 {
    draw_char(x, y + i, chars.vertical)
    draw_char(x + width - 1, y + i, chars.vertical)
  }
  
  // Title
  match self.title {
    Some(title) => {
      let title_x = x + width / 2 - title.length() / 2
      if title_x > x && title_x + title.length() < x + width {
        ctx.buffer.draw_text(
          title,
          title_x.reinterpret_as_uint(),
          y.reinterpret_as_uint(),
          fg_r=self.border_color.r,
          fg_g=self.border_color.g,
          fg_b=self.border_color.b,
          bg_r=Some(self.background.r),
          bg_g=Some(self.background.g),
          bg_b=Some(self.background.b)
        )
      }
    }
    None => ()
  }
}

fn BoxView::layout_children_ffi(self : BoxView, ctx : FFIRenderContext) -> Unit {
  // For now, just render first child filling the space
  if self.children.length() > 0 {
    self.children[0].render_ffi(ctx)
  }
}

/// Text rendering directly to FFI
pub fn TextView::render_ffi(self : TextView, ctx : FFIRenderContext) -> Unit {
  let lines = self.wrap_text(ctx.bounds.width)
  let mut y = ctx.bounds.y
  
  for line in lines {
    if y >= ctx.bounds.y + ctx.bounds.height {
      break
    }
    
    let x = match self.align {
      TextAlign::Left => ctx.bounds.x
      TextAlign::Center => ctx.bounds.x + (ctx.bounds.width - line.length()) / 2
      TextAlign::Right => ctx.bounds.x + ctx.bounds.width - line.length()
    }
    
    // Convert style to attributes
    let (bold, underline) = match self.style {
      TextStyle::Bold => (true, false)
      TextStyle::Underline => (false, true)
      _ => (false, false)
    }
    
    ctx.buffer.draw_text(
      line,
      x.reinterpret_as_uint(),
      y.reinterpret_as_uint(),
      fg_r=self.color.r,
      fg_g=self.color.g,
      fg_b=self.color.b,
      bold=bold,
      underline=underline
    )
    
    y = y + 1
  }
}

/// Group rendering - just render children
pub fn GroupView::render_ffi(self : GroupView, ctx : FFIRenderContext) -> Unit {
  for child in self.children {
    child.render_ffi(ctx)
  }
}

/// VStack rendering (Yoga-based)
pub fn VStackView::render_ffi(self : VStackView, ctx : FFIRenderContext) -> Unit {
  // Build Yoga tree: root node sized to bounds
  let root = @wrapper.Node::new()
  root.set_flex_direction(@types.FlexDirection::Column)
  root.set_width_points(ctx.bounds.width.to_double().to_float())
  root.set_height_points(ctx.bounds.height.to_double().to_float())

  // Add children as flex items
  for i = 0; i < self.children.length(); i = i + 1 {
    let n = @wrapper.Node::new()
    // Equal distribution via flex-grow=1
    n.set_flex_grow(1.0)
    // Spacing via bottom margin except last
    if i < self.children.length() - 1 {
      n.set_margin(@types.Edge::Bottom, @types.Value::point(self.spacing.to_double().to_float()))
    }
    root.add_child(n)
  }

  // Calculate layout
  root.calculate_layout(
    ctx.bounds.width.to_double().to_float(),
    ctx.bounds.height.to_double().to_float(),
    @types.Direction::LTR,
  )

  // Render children according to computed layouts
  for i = 0; i < self.children.length(); i = i + 1 {
    match root.get_child(i) {
      Some(child_node) => {
        let left = child_node.layout_left().to_double().to_int()
        let top = child_node.layout_top().to_double().to_int()
        let width = child_node.layout_width().to_double().to_int()
        let height = child_node.layout_height().to_double().to_int()
        let child_bounds = Rect::new(
          ctx.bounds.x + left,
          ctx.bounds.y + top,
          width,
          height,
        )
        self.children[i].render_ffi(FFIRenderContext::{ buffer: ctx.buffer, bounds: child_bounds })
      }
      None => ()
    }
  }
}

/// HStack rendering (Yoga-based)
pub fn HStackView::render_ffi(self : HStackView, ctx : FFIRenderContext) -> Unit {
  let root = @wrapper.Node::new()
  root.set_flex_direction(@types.FlexDirection::Row)
  root.set_width_points(ctx.bounds.width.to_double().to_float())
  root.set_height_points(ctx.bounds.height.to_double().to_float())

  for i = 0; i < self.children.length(); i = i + 1 {
    let n = @wrapper.Node::new()
    n.set_flex_grow(1.0)
    if i < self.children.length() - 1 {
      n.set_margin(@types.Edge::Right, @types.Value::point(self.spacing.to_double().to_float()))
    }
    root.add_child(n)
  }

  root.calculate_layout(
    ctx.bounds.width.to_double().to_float(),
    ctx.bounds.height.to_double().to_float(),
    @types.Direction::LTR,
  )

  for i = 0; i < self.children.length(); i = i + 1 {
    match root.get_child(i) {
      Some(child_node) => {
        let left = child_node.layout_left().to_double().to_int()
        let top = child_node.layout_top().to_double().to_int()
        let width = child_node.layout_width().to_double().to_int()
        let height = child_node.layout_height().to_double().to_int()
        let child_bounds = Rect::new(
          ctx.bounds.x + left,
          ctx.bounds.y + top,
          width,
          height,
        )
        self.children[i].render_ffi(FFIRenderContext::{ buffer: ctx.buffer, bounds: child_bounds })
      }
      None => ()
    }
  }
}

/// ZStack rendering
pub fn ZStackView::render_ffi(self : ZStackView, ctx : FFIRenderContext) -> Unit {
  // Render all children in same bounds (overlapping)
  for child in self.children {
    child.render_ffi(ctx)
  }
}

/// Spacer rendering
pub fn SpacerView::render_ffi(self : SpacerView, ctx : FFIRenderContext) -> Unit {
  // Spacer renders nothing
}

/// Padding rendering
pub fn PaddingView::render_ffi(self : PaddingView, ctx : FFIRenderContext) -> Unit {
  // Use Yoga to compute inner padded area for the single child
  let root = @wrapper.Node::new()
  root.set_width_points(ctx.bounds.width.to_double().to_float())
  root.set_height_points(ctx.bounds.height.to_double().to_float())
  root.set_padding_all(@types.Value::point(self.amount.to_double().to_float()))

  let child_node = @wrapper.Node::new()
  child_node.set_flex_grow(1.0)
  root.add_child(child_node)

  root.calculate_layout(ctx.bounds.width.to_double().to_float(), ctx.bounds.height.to_double().to_float(), @types.Direction::LTR)

  match root.get_child(0) {
    Some(n) => {
      let left = n.layout_left().to_double().to_int()
      let top = n.layout_top().to_double().to_int()
      let w = n.layout_width().to_double().to_int()
      let h = n.layout_height().to_double().to_int()
      let pb = Rect::new(ctx.bounds.x + left, ctx.bounds.y + top, w, h)
      self.child.render_ffi(FFIRenderContext::{ buffer: ctx.buffer, bounds: pb })
    }
    None => ()
  }
}

/// InteractView rendering - render child with interaction
pub fn InteractView::render_ffi(self : InteractView, ctx : FFIRenderContext) -> Unit {
  // Simply render the child for now
  self.child.render_ffi(ctx)
}
