///| View component - base container using Yoga layout

///|
/// Similar to React Native's View or HTML's div
pub struct View {
  // Layout
  yoga_node : @wrapper.Node
  mut layout_props : LayoutProps
  mut computed : ComputedLayout?

  // Style
  mut background_color : @core.Color?
  mut border_color : @core.Color?
  mut border_style : BorderStyle?

  // Children
  mut children : Array[View]

  // Content (for leaf nodes)
  mut text_content : String?
  mut text_provider : (() -> String)?
  mut text_lines : Array[String]?
  mut text_color : @core.Color?

  // Events
  mut on_click : ((Int, Int) -> Unit)?
  mut on_key : ((@ffi.KeyEvent) -> Bool)?
  mut on_key_mod : ((@ffi.KeyEvent, @ffi.KeyModifiers) -> Bool)?
  mut id : Int
  mut focusable : Bool
  
  // Theming
  mut theme : @core.Theme?
  
  // Scrolling / clipping
  mut clip_children : Bool
  mut scroll_y : Int

  // Behavior flags
  mut wrap_to_layout : Bool
  mut is_focus_trap : Bool
  mut scrollable : Bool

  // Cursor/caret providers for editable text
  mut cursor_col_provider : (() -> Int)?
  mut cursor_visible_provider : (() -> Bool)?
}

///|
pub(all) enum BorderStyle {
  None
  Single
  Double
  Rounded
}

///|
pub fn View::new() -> View {
  let config = @wrapper.Config::default()
  let node = @wrapper.Node::new_with_config(config)
  {
    yoga_node: node,
    layout_props: default_layout_props(),
    computed: None,
    background_color: None,
    border_color: None,
    border_style: None,
    children: [],
    text_content: None,
    text_provider: None,
    text_lines: None,
    text_color: None,
    on_click: None,
    on_key: None,
    on_key_mod: None,
    id: 0,
    focusable: false,
    theme: None,
    clip_children: false,
    scroll_y: 0,
    wrap_to_layout: false,
    is_focus_trap: false,
    scrollable: false,
    cursor_col_provider: None,
    cursor_visible_provider: None,
  }
}

///|
fn default_layout_props() -> LayoutProps {
  {
    flex_grow: None,
    flex_shrink: None,
    flex_basis: None,
    flex_direction: None,
    flex_wrap: None,
    align_items: None,
    align_self: None,
    align_content: None,
    justify_content: None,
    width: None,
    height: None,
    min_width: None,
    min_height: None,
    max_width: None,
    max_height: None,
    padding: None,
    margin: None,
    gap: None,
    row_gap: None,
    column_gap: None,
    position_type: None,
    top: None,
    right: None,
    bottom: None,
    left: None,
  }
}

// Builder pattern for View

///|
pub fn View::flex_direction(self : View, dir : @types.FlexDirection) -> View {
  let new_props = { ..self.layout_props, flex_direction: Some(dir) }
  apply_layout_to_node(self.yoga_node, new_props)
  { ..self, layout_props: new_props }
}

///|
pub fn View::justify_content(self : View, justify : @types.Justify) -> View {
  let new_props = { ..self.layout_props, justify_content: Some(justify) }
  apply_layout_to_node(self.yoga_node, new_props)
  { ..self, layout_props: new_props }
}

///|
pub fn View::align_items(self : View, align : @types.Align) -> View {
  let new_props = { ..self.layout_props, align_items: Some(align) }
  apply_layout_to_node(self.yoga_node, new_props)
  { ..self, layout_props: new_props }
}

///|
pub fn View::padding(self : View, value : Double) -> View {
  self.layout_props.padding = Some(EdgeValues::all(value))
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
/// Enable or disable clipping for this view's content and children
pub fn View::clip_children(self : View, enabled : Bool) -> View {
  self.clip_children = enabled
  self
}

///|
pub fn View::padding_symmetric(self : View, vertical : Double, horizontal : Double) -> View {
  self.layout_props.padding = Some(EdgeValues::symmetric(vertical, horizontal))
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::margin(self : View, value : Double) -> View {
  self.layout_props.margin = Some(EdgeValues::all(value))
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::margin_symmetric(self : View, vertical : Double, horizontal : Double) -> View {
  self.layout_props.margin = Some(EdgeValues::symmetric(vertical, horizontal))
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

/// Set top margin
pub fn View::margin_top(self : View, value : Double) -> View {
  self.yoga_node.set_margin(@types.Edge::Top, @types.Value::point(value.to_float()))
  self
}

///|
pub fn View::flex(self : View, value : Double) -> View {
  self.layout_props.flex_grow = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::flex_grow(self : View, value : Double) -> View {
  self.layout_props.flex_grow = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::flex_shrink(self : View, value : Double) -> View {
  self.layout_props.flex_shrink = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
/// Set uniform gap between children
pub fn View::gap(self : View, value : Double) -> View {
  self.layout_props.gap = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
/// Set row gap between children
pub fn View::row_gap(self : View, value : Double) -> View {
  self.layout_props.row_gap = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
/// Set column gap between children
pub fn View::column_gap(self : View, value : Double) -> View {
  self.layout_props.column_gap = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::width(self : View, value : @types.Value) -> View {
  self.layout_props.width = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::width_percent(self : View, pct : Double) -> View {
  self.width(@types.Value::percent(pct.to_float()))
}

///|
pub fn View::width_auto(self : View) -> View {
  self.width(@types.Value::auto())
}

///|
pub fn View::height(self : View, value : @types.Value) -> View {
  self.layout_props.height = Some(value)
  apply_layout_to_node(self.yoga_node, self.layout_props)
  self
}

///|
pub fn View::height_percent(self : View, pct : Double) -> View {
  self.height(@types.Value::percent(pct.to_float()))
}

///|
pub fn View::height_auto(self : View) -> View {
  self.height(@types.Value::auto())
}

/// Set position type
pub fn View::position(self : View, pos : @types.PositionType) -> View {
  self.layout_props.position_type = Some(pos)
  match pos {
    @types.PositionType::Absolute => self.yoga_node.set_position_type(@types.PositionType::Absolute)
    @types.PositionType::Relative => self.yoga_node.set_position_type(@types.PositionType::Relative)
    @types.PositionType::Static => self.yoga_node.set_position_type(@types.PositionType::Static)
  }
  self
}

/// Set top position
pub fn View::top(self : View, value : @types.Value) -> View {
  self.layout_props.top = Some(value)
  self.yoga_node.set_position(@types.Edge::Top, value)
  self
}

/// Set left position
pub fn View::left(self : View, value : @types.Value) -> View {
  self.layout_props.left = Some(value)
  self.yoga_node.set_position(@types.Edge::Left, value)
  self
}

/// Set visibility
pub fn View::visible(self : View, visible : Bool) -> View {
  self.layout_props.position_type = if visible { None } else { Some(@types.PositionType::Static) }
  // TODO: Actually handle display none in rendering
  self
}

///|
/// Convenience: set flex direction row
pub fn View::row(self : View) -> View {
  self.flex_direction(@types.FlexDirection::Row)
}

///|
/// Convenience: set flex direction column
pub fn View::column(self : View) -> View {
  self.flex_direction(@types.FlexDirection::Column)
}

///|
/// Convenience: center both axes
pub fn View::center(self : View) -> View {
  self
    .justify_content(@types.Justify::Center)
    .align_items(@types.Align::Center)
}

///|
pub fn View::align_self(self : View, align : @types.Align) -> View {
  let new_props = { ..self.layout_props, align_self: Some(align) }
  apply_layout_to_node(self.yoga_node, new_props)
  { ..self, layout_props: new_props }
}

///|
pub fn View::align_content(self : View, align : @types.Align) -> View {
  let new_props = { ..self.layout_props, align_content: Some(align) }
  apply_layout_to_node(self.yoga_node, new_props)
  { ..self, layout_props: new_props }
}

///|
pub fn View::justify_start(self : View) -> View { self.justify_content(@types.Justify::FlexStart) }
///|
pub fn View::justify_center(self : View) -> View { self.justify_content(@types.Justify::Center) }
///|
pub fn View::justify_end(self : View) -> View { self.justify_content(@types.Justify::FlexEnd) }
///|
pub fn View::justify_between(self : View) -> View { self.justify_content(@types.Justify::SpaceBetween) }
///|
pub fn View::justify_around(self : View) -> View { self.justify_content(@types.Justify::SpaceAround) }
///|
pub fn View::justify_evenly(self : View) -> View { self.justify_content(@types.Justify::SpaceEvenly) }

///|
pub fn View::background(self : View, color : @core.Color) -> View {
  self.background_color = Some(color)
  self
}

///|
/// Register on-click handler; coordinates passed are relative to the view
pub fn View::on_click(self : View, handler : (Int, Int) -> Unit) -> View {
  self.on_click = Some(handler)
  self
}

///|
/// Register a key handler; return true to consume the key
pub fn View::on_key(self : View, handler : (@ffi.KeyEvent) -> Bool) -> View {
  self.on_key = Some(handler)
  self
}

///|
/// Register a key handler with modifiers; return true to consume the key
pub fn View::on_key_mod(self : View, handler : (@ffi.KeyEvent, @ffi.KeyModifiers) -> Bool) -> View {
  self.on_key_mod = Some(handler)
  self
}

///|
/// Mark this view as focusable for keyboard navigation
pub fn View::focusable(self : View, value? : Bool = true) -> View {
  self.focusable = value
  self
}

/// Enable focus trap - focus cannot leave this view's children
pub fn View::focus_trap(self : View, value? : Bool = true) -> View {
  self.is_focus_trap = value
  self
}

///|
/// Apply a theme to this view (used when explicit colors are not set)
pub fn View::theme(self : View, theme : @core.Theme) -> View {
  self.theme = Some(theme)
  self
}

///|
/// Prefer theme accent color for text (if theme present)
pub fn View::use_accent(self : View) -> View {
  match self.theme {
    Some(t) => self.text_color = Some(t.accent)
    None => ()
  }
  self
}

///|
pub fn View::border(
  self : View,
  style : BorderStyle,
  color : @core.Color,
) -> View {
  self.border_style = Some(style)
  self.border_color = Some(color)
  // TODO: Yoga doesn't have set_border, need to handle border width differently
  // For now, borders are visual only and don't affect layout
  self
}

///|
/// Mark this view as scrollable for input handling (navigation)
pub fn View::scrollable(self : View, value? : Bool = true) -> View {
  self.scrollable = value
  self
}

///|
/// Set vertical scroll offset for this view
pub fn View::scroll(self : View, y : Int) -> View {
  self.scroll_y = y
  self
}

///|
/// Enable wrapping this view's text to its Yoga-computed layout width after initial layout
pub fn View::wrap_to_layout(self : View, value? : Bool = true) -> View {
  self.wrap_to_layout = value
  self
}

// Add a child view

///|
pub fn View::add_child(self : View, child : View) -> View {
  self.children.push(child)
  // Insert child's Yoga node
  self.yoga_node.insert_child(child.yoga_node, self.children.length() - 1)
  self
}

///|
/// Add multiple children at once
pub fn View::children(self : View, items : Array[View]) -> View {
  for child in items {
    // push and insert in Yoga tree
    self.children.push(child)
    self.yoga_node.insert_child(child.yoga_node, self.children.length() - 1)
  }
  self
}

// Create a text view

///|
pub fn View::text(content : String, color : @core.Color?) -> View {
  let view = View::new()
  view.text_content = Some(content)
  view.text_color = color

  // Text has intrinsic size
  let width = content.length().to_double()
  let height = 1.0 // Single line for now
  view.yoga_node.set_width_points(width.to_float())
  view.yoga_node.set_height_points(height.to_float())
  view
}

///|
/// Bind a dynamic text provider; content is read at layout/render time
pub fn View::text_bind(self : View, provider : () -> String, color? : @core.Color = @core.Color::White) -> View {
  self.text_provider = Some(provider)
  self.text_color = Some(color)
  self
}

///|
/// Bind caret position and visibility providers for editable text views
pub fn View::cursor_bind(self : View, col_provider : () -> Int, visible_provider? : () -> Bool = fn() { true }) -> View {
  self.cursor_col_provider = Some(col_provider)
  self.cursor_visible_provider = Some(visible_provider)
  self
}

///|
/// Create a text view with simple word-wrapping to a maximum width (in cells)
pub fn View::text_wrapped(content : String, max_width : Int, color : @core.Color?) -> View {
  let lines : Array[String] = []
  let mut current = ""
  for wsv in content.split(" ") {
    let w = wsv.to_string()
    let candidate = if current.length() == 0 { w } else { current + " " + w }
    if candidate.length() <= max_width {
      current = candidate
    } else {
      if current.length() > 0 { lines.push(current) }
      current = w
    }
  }
  if current.length() > 0 { lines.push(current) }

  let view = View::new()
  view.text_lines = Some(lines)
  view.text_color = color
  view.yoga_node.set_width_points(max_width.to_double().to_float())
  let h = view.text_lines.unwrap_or([]).length().to_double()
  view.yoga_node.set_height_points(h.to_float())
  view
}

///|
/// Convenience: measure this view's text using simple heuristics until Yoga measure callbacks land.
/// - When wrap=false: sizes to one line (width = content length, height = 1)
/// - When wrap=true: word-wraps to max_width and sets height to number of lines
pub fn View::measure_text(self : View, wrap : Bool, max_width? : Int = 80) -> View {
  match self.text_content {
    Some(content) => {
      if wrap {
        // Compute wrapped lines and fixed height
        let lines : Array[String] = []
        let mut current = ""
        for wsv in content.split(" ") {
          let w = wsv.to_string()
          let candidate = if current.length() == 0 { w } else { current + " " + w }
          if candidate.length() <= max_width { current = candidate } else {
            if current.length() > 0 { lines.push(current) }
            current = w
          }
        }
        if current.length() > 0 { lines.push(current) }
        self.text_lines = Some(lines)
        // Use Yoga measure with fixed size
        self.yoga_node.clear_measure()
        self.yoga_node.set_measure_fixed(max_width.to_double().to_float(), self.text_lines.unwrap_or([]).length().to_double().to_float())
        // Ensure style width/height are auto so measure is used
        self.yoga_node.set_width_auto()
        self.yoga_node.set_height_auto()
      } else {
        // Single-line intrinsic size
        self.text_lines = None
        let w = content.length().to_double().to_float()
        self.yoga_node.clear_measure()
        self.yoga_node.set_measure_fixed(w, 1.0)
        self.yoga_node.set_width_auto()
        self.yoga_node.set_height_auto()
      }
    }
    None => ()
  }
  self
}

///|
/// Auto-size this view to fit its single-line text content (if any)
pub fn View::auto_size_text(self : View) -> View {
  match self.text_content {
    Some(content) => {
      self.yoga_node.set_width_points(content.length().to_double().to_float())
      self.yoga_node.set_height_points(1.0)
    }
    None => ()
  }
  self
}

///|
/// Wrap this view's text to the given max width and auto-set height
pub fn View::auto_wrap(self : View, max_width : Int) -> View {
  match self.text_content {
    Some(content) => {
      let lines : Array[String] = []
      let mut current = ""
      for wsv in content.split(" ") {
        let w = wsv.to_string()
        let candidate = if current.length() == 0 { w } else { current + " " + w }
        if candidate.length() <= max_width {
          current = candidate
        } else {
          if current.length() > 0 { lines.push(current) }
          current = w
        }
      }
      if current.length() > 0 { lines.push(current) }
      self.text_lines = Some(lines)
      self.yoga_node.set_width_points(max_width.to_double().to_float())
      let h = self.text_lines.unwrap_or([]).length().to_double()
      self.yoga_node.set_height_points(h.to_float())
    }
    None => ()
  }
  self
}

// Calculate layout for entire tree

///|
pub fn View::calculate_layout(
  self : View,
  available_width : Double,
  available_height : Double,
) -> Unit {
  self.yoga_node.calculate_layout(
    available_width.to_float(),
    available_height.to_float(),
    @types.Direction::LTR,
  )

  // Store computed layout
  self.update_computed_layout()

  // If any view requests wrapping to layout width, adjust measures and re-layout once
  if self.apply_auto_wrap_from_layout() {
    self.yoga_node.calculate_layout(
      available_width.to_float(),
      available_height.to_float(),
      @types.Direction::LTR,
    )
    self.update_computed_layout()
    for i = 0; i < self.children.length(); i = i + 1 {
      self.children[i].update_computed_layout()
    }
  }

  // Update children
  for i = 0; i < self.children.length(); i = i + 1 {
    self.children[i].update_computed_layout()
  }
}

///|
/// Internal: adjust text measure based on Yoga-computed width for views with wrap_to_layout
fn View::apply_auto_wrap_from_layout(self : View) -> Bool {
  let mut changed = false
  // Apply to self if needed
  if self.wrap_to_layout {
    let has_text = match (self.text_content, self.text_provider) {
      (Some(_), _) => true
      (_, Some(_)) => true
      _ => false
    }
    if has_text {
      match self.computed {
        Some(layout) => {
          let raw_w = layout.width.to_int()
          let wrap_w = if raw_w > 2 { raw_w - 2 } else { raw_w }
          if wrap_w > 0 {
            let source = match self.text_provider {
              Some(p) => p()
              None => self.text_content.unwrap_or("")
            }
            let lines : Array[String] = []
            let mut current = ""
            for wsv in source.split(" ") {
              let w = wsv.to_string()
              let candidate = if current.length() == 0 { w } else { current + " " + w }
              if candidate.length() <= wrap_w {
                current = candidate
              } else {
                if current.length() > 0 { lines.push(current) }
                current = w
              }
            }
            if current.length() > 0 { lines.push(current) }
            self.text_lines = Some(lines)
            self.yoga_node.clear_measure()
            self.yoga_node.set_measure_fixed(wrap_w.to_double().to_float(), self.text_lines.unwrap_or([]).length().to_double().to_float())
            self.yoga_node.set_width_auto()
            self.yoga_node.set_height_auto()
            changed = true
          }
        }
        None => ()
      }
    }
  }

  // Recurse into children
  for i = 0; i < self.children.length(); i = i + 1 {
    if self.children[i].apply_auto_wrap_from_layout() { changed = true }
  }
  changed
}

///|
fn View::update_computed_layout(self : View) -> Unit {
  let x = self.yoga_node.layout_left().to_double()
  let y = self.yoga_node.layout_top().to_double()
  let width = self.yoga_node.layout_width().to_double()
  let height = self.yoga_node.layout_height().to_double()
  self.computed = Some({
    x: x,
    y: y,
    width: width,
    height: height,
  })

  // Recursively update children
  for i = 0; i < self.children.length(); i = i + 1 {
    self.children[i].update_computed_layout()
  }
}

// Render the view tree

///| Render the view to a buffer using Yoga's computed layout
pub fn View::render(
  self : View,
  buffer : @ffi.Buffer,
  parent_x? : Int = 0,
  parent_y? : Int = 0,
) -> Unit {
  match self.computed {
    None => return // Not laid out yet
    Some(layout) => {
      let x = parent_x + layout.x.to_int()
      let y = parent_y + layout.y.to_int()
      let width = layout.width.to_int()
      let height = layout.height.to_int()

      // Optional clipping region for this view
      if self.clip_children {
        buffer.push_scissor(x, y, width, height)
      }

      // Draw background: explicit color, otherwise theme bg if present
      let (bg_r, bg_g, bg_b) = match self.background_color {
        Some(c) => @core.color_to_rgb(c)
        None => {
          match self.theme {
            Some(t) => @core.color_to_rgb(t.bg)
            None => (0.0, 0.0, 0.0)
          }
        }
      }
      buffer.fill_rect(
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        width.reinterpret_as_uint(),
        height.reinterpret_as_uint(),
        bg_r, bg_g, bg_b, 1.0,
      )

      // Draw border if style set; prefer explicit border color, else theme accent
      match self.border_style {
        Some(_) => {
          let (br, bg, bb) = match self.border_color {
            Some(c) => @core.color_to_rgb(c)
            None => {
              match self.theme {
                Some(t) => @core.color_to_rgb(t.accent)
                None => (1.0, 1.0, 1.0)
              }
            }
          }
          buffer.fill_rect(x.reinterpret_as_uint(), y.reinterpret_as_uint(), width.reinterpret_as_uint(), 1, br, bg, bb, 1.0)
          buffer.fill_rect(x.reinterpret_as_uint(), (y + height - 1).reinterpret_as_uint(), width.reinterpret_as_uint(), 1, br, bg, bb, 1.0)
          buffer.fill_rect(x.reinterpret_as_uint(), y.reinterpret_as_uint(), 1, height.reinterpret_as_uint(), br, bg, bb, 1.0)
          buffer.fill_rect((x + width - 1).reinterpret_as_uint(), y.reinterpret_as_uint(), 1, height.reinterpret_as_uint(), br, bg, bb, 1.0)
        }
        None => ()
      }

      // Draw text content if present
      let text_color = match self.text_color {
        Some(c) => c
        None => {
          match self.theme {
            Some(t) => t.fg
            None => @core.Color::White
          }
        }
      }
      let (r, g, b) = @core.color_to_rgb(text_color)
      let inset = match self.border_style {
        Some(_) => 1
        None => 0
      }
      match self.text_lines {
        Some(lines) => {
          for i = 0; i < lines.length(); i = i + 1 {
            buffer.draw_text(
              lines[i],
              (x + inset).reinterpret_as_uint(),
              (y + inset + i - self.scroll_y).reinterpret_as_uint(),
              fg_r=r, fg_g=g, fg_b=b,
            )
          }
        }
        None => {
          match self.text_content {
            Some(text) => buffer.draw_text(
              text,
              (x + inset).reinterpret_as_uint(),
              (y + inset - self.scroll_y).reinterpret_as_uint(),
              fg_r=r, fg_g=g, fg_b=b,
            )
            None => match self.text_provider {
              Some(p) => buffer.draw_text(
                p(),
                (x + inset).reinterpret_as_uint(),
                (y + inset - self.scroll_y).reinterpret_as_uint(),
                fg_r=r, fg_g=g, fg_b=b,
              )
              None => ()
            }
          }
        }
      }

      // Draw caret if bound
      match (self.cursor_col_provider, self.cursor_visible_provider) {
        (Some(get_col), Some(is_vis)) => {
          if is_vis() {
            let col = get_col()
            let (cr, cg, cb) = match self.theme {
              Some(t) => @core.color_to_rgb(t.accent)
              None => (1.0, 1.0, 1.0)
            }
            let cx = x + 1 + col
            let cy = y + 1 - self.scroll_y
            buffer.fill_rect(cx.reinterpret_as_uint(), cy.reinterpret_as_uint(), 1, 1, cr, cg, cb, 1.0)
          }
        }
        _ => ()
      }

      // Render children relative to this view's position
      for i = 0; i < self.children.length(); i = i + 1 {
        self.children[i].render(buffer, parent_x=x, parent_y=y - self.scroll_y)
      }

      // Pop clipping if it was pushed
      if self.clip_children {
        buffer.pop_scissor()
      }

    }

  }
}

// Naive word-wrap: wraps by spaces to keep line length <= max_width
// (no-op)

// Using @core.color_to_rgb for color conversion
