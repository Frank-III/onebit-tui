///| Simplified View type - just a rendering primitive

///|
/// Components produce Views, Views are rendered to screen

// Global counter for view IDs
let view_id_counter : Ref[Int] = Ref::new(1000)

///|
pub struct View {
  // Layout properties
  mut width : Size?
  mut height : Size?
  mut flex_value : Double?
  mut layout_direction : Direction?
  mut spacing : Double?
  mut padding_value : Double?
  mut margin_value : Double?
  mut align_items_value : @types.Align?
  mut justify_content_value : @types.Justify?

  // Style properties  
  mut bg_color : @core.Color?
  mut fg_color : @core.Color?
  mut border_style : BorderStyle?
  mut border_color : @core.Color?
  mut focused_border_color : @core.Color?
  mut title_text : String?
  mut title_align : TitleAlign?

  // Position
  mut position_type : Position?
  mut top_offset : Double?
  mut left_offset : Double?

  // Content
  content : ViewContent

  // Children
  children : Array[View]

  // Event handling (simplified)
  mut key_handler : ((@ffi.KeyEvent) -> Bool)?
  mut click_handler : ((Int, Int) -> Unit)?

  // Focus
  mut is_focusable : Bool
  mut is_focused : Bool
  mut view_id : Int?

  // Overflow
  mut overflow_y : Overflow?
}

///|
pub(all) enum Size {
  Fixed(Double)
  Percent(Double)
  Auto
}

///|
pub(all) enum Direction {
  Row
  Column
}

///|
pub(all) enum Position {
  Relative
  Absolute
}

///|
pub(all) enum BorderStyle {
  None
  Single
  Double
  Rounded
}

///|
pub(all) enum ViewContent {
  Empty
  Text(String)
}

///|
pub(all) enum Overflow {
  Visible
  Hidden
  Scroll
}

///|
pub(all) enum TitleAlign {
  Left
  Center
  Right
}

///|
/// Create an empty view
pub fn View::empty() -> View {
  {
    width: None,
    height: None,
    flex_value: None,
    layout_direction: None,
    spacing: None,
    padding_value: None,
    margin_value: None,
    align_items_value: None,
    justify_content_value: None,
    bg_color: None,
    fg_color: None,
    border_style: None,
    border_color: None,
    focused_border_color: None,
    title_text: None,
    title_align: None,
    position_type: None,
    top_offset: None,
    left_offset: None,
    content: ViewContent::Empty,
    children: [],
    key_handler: None,
    click_handler: None,
    is_focusable: false,
    is_focused: false,
    view_id: None,
    overflow_y: None,
  }
}

///|
/// Create a text view
pub fn View::text(
  text : String,
  color? : @core.Color = @core.Color::White,
) -> View {
  {
    width: None,
    height: None,
    flex_value: None,
    layout_direction: None,
    spacing: None,
    padding_value: None,
    margin_value: None,
    align_items_value: None,
    justify_content_value: None,
    bg_color: None,
    fg_color: Some(color),
    border_style: None,
    border_color: None,
    focused_border_color: None,
    title_text: None,
    title_align: None,
    position_type: None,
    top_offset: None,
    left_offset: None,
    content: ViewContent::Text(text),
    children: [],
    key_handler: None,
    click_handler: None,
    is_focusable: false,
    is_focused: false,
    view_id: None,
    overflow_y: None,
  }
}

///|
/// Create a container view from View array (low-level)
pub fn View::container_views(children : Array[View]) -> View {
  {
    width: None,
    height: None,
    flex_value: None,
    layout_direction: None,
    spacing: None,
    padding_value: None,
    margin_value: None,
    align_items_value: None,
    justify_content_value: None,
    bg_color: None,
    fg_color: None,
    border_style: None,
    border_color: None,
    focused_border_color: None,
    title_text: None,
    title_align: None,
    position_type: None,
    top_offset: None,
    left_offset: None,
    content: ViewContent::Empty,
    children,
    key_handler: None,
    click_handler: None,
    is_focusable: false,
    is_focused: false,
    view_id: None,
    overflow_y: None,
  }
}

// Builder methods for chaining

///|
pub fn View::width(self : View, w : Double) -> View {
  self.width = Some(Size::Fixed(w))
  self
}

///|
pub fn View::height(self : View, h : Double) -> View {
  self.height = Some(Size::Fixed(h))
  self
}

///|
pub fn View::flex(self : View, f : Double) -> View {
  self.flex_value = Some(f)
  self
}

///|
pub fn View::padding(self : View, p : Double) -> View {
  self.padding_value = Some(p)
  self
}

///|
pub fn View::margin(self : View, m : Double) -> View {
  self.margin_value = Some(m)
  self
}

///|
pub fn View::background(self : View, color : @core.Color) -> View {
  self.bg_color = Some(color)
  self
}

///|
pub fn View::foreground(self : View, color : @core.Color) -> View {
  self.fg_color = Some(color)
  self
}

///|
pub fn View::border(
  self : View,
  style : BorderStyle,
  color? : @core.Color = @core.Color::Gray,
) -> View {
  self.border_style = Some(style)
  self.border_color = Some(color)
  self
}

///|
pub fn View::focused_border_color(self : View, color : @core.Color) -> View {
  self.focused_border_color = Some(color)
  self
}

///|
/// Set an optional title for bordered containers
pub fn View::title(self : View, text : String) -> View {
  self.title_text = Some(text)
  self
}

///|
pub fn View::title_align(self : View, align : TitleAlign) -> View {
  self.title_align = Some(align)
  self
}

///|
pub fn View::direction(self : View, dir : Direction) -> View {
  self.layout_direction = Some(dir)
  self
}

///|
pub fn View::spacing(self : View, s : Double) -> View {
  self.spacing = Some(s)
  self
}

///|
pub fn View::focusable(self : View, f? : Bool = true) -> View {
  self.is_focusable = f
  // Auto-assign ID if focusable and doesn't have one
  if f {
    match self.view_id {
      None => {
        self.view_id = Some(view_id_counter.val)
        view_id_counter.val = view_id_counter.val + 1
      }
      Some(_) => ()
    }
  }
  self
}

///|
pub fn View::on_key(self : View, handler : (@ffi.KeyEvent) -> Bool) -> View {
  self.key_handler = Some(handler)
  self.is_focusable = true
  // Auto-assign ID if doesn't have one
  match self.view_id {
    None => {
      self.view_id = Some(view_id_counter.val)
      view_id_counter.val = view_id_counter.val + 1
    }
    Some(_) => ()
  }
  self
}

///|
pub fn View::on_click(self : View, handler : ((Int, Int) -> Unit)?) -> View {
  self.click_handler = handler
  self
}

///|
/// Assign a stable view ID (useful across rebuilds for focus/dispatch)
pub fn View::id(self : View, id : Int) -> View {
  self.view_id = Some(id)
  self
}

///|
pub fn View::align_items(self : View, align : @types.Align) -> View {
  self.align_items_value = Some(align)
  self
}

///|
pub fn View::justify_content(self : View, justify : @types.Justify) -> View {
  self.justify_content_value = Some(justify)
  self
}

///|
pub fn View::overflow_y(self : View, overflow : Overflow) -> View {
  self.overflow_y = Some(overflow)
  self
}

///|
/// Set position type (relative or absolute)
pub fn View::position(self : View, pos : Position) -> View {
  self.position_type = Some(pos)
  self
}

///|
/// Set top offset for positioned elements
pub fn View::top(self : View, offset : Double) -> View {
  self.top_offset = Some(offset)
  self
}

///|
/// Set left offset for positioned elements
pub fn View::left(self : View, offset : Double) -> View {
  self.left_offset = Some(offset)
  self
}

///|
/// Helper for margin-top (using Yoga's margin edge)
pub fn View::margin_top(self : View, m : Double) -> View {
  // This would need proper edge-specific margin support in the struct
  // For now, we'll use general margin as a workaround
  self.margin_value = Some(m)
  self
}

///|
/// Set focus state - used by event dispatcher
pub fn View::set_focused(self : View, focused : Bool) -> Unit {
  self.is_focused = focused
}

///|
/// Component trait - all UI elements implement this
/// Using pub(open) so types in other modules can implement it
pub(open) trait Component {
  /// Render this component to a View tree
  render(Self) -> View

  /// Handle any event (return true if handled)
  handle_event(Self, @events.Event) -> Bool

  /// Whether this component can receive focus
  is_focusable(Self) -> Bool
}

///|
/// Create a container from components - this is the primary container API
pub fn View::container(components : Array[&Component]) -> View {
  let views : Array[View] = []
  for i = 0; i < components.length(); i = i + 1 {
    views.push(components[i].render())
  }
  View::container_views(views)
}
