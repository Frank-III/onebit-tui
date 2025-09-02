///| Core view system for OneBit-TUI
///| Provides a clean, composable API for building terminal UIs

/// Enumeration of all view types for polymorphic collections
pub enum View {
  Box(BoxView)
  Text(TextView) 
  Group(GroupView)
  VStack(VStackView)
  HStack(HStackView)
  ZStack(ZStackView)
  Spacer(SpacerView)
  Padding(PaddingView)
  Interact(InteractView)
}

/// Core rendering context
pub struct RenderContext {
  buffer : TerminalBuffer
  bounds : Rect
}

/// Size constraints for layout
pub struct Constraints {
  min_width : Int
  max_width : Int
  min_height : Int
  max_height : Int
}

/// Size result from measurement
pub struct ViewSize {
  width : Int
  height : Int
}

/// Render any view
pub fn View::render(self : View, ctx : RenderContext) -> Unit {
  match self {
    Box(v) => v.render(ctx)
    Text(v) => v.render(ctx)
    Group(v) => v.render(ctx)
    VStack(v) => v.render(ctx)
    HStack(v) => v.render(ctx)
    ZStack(v) => v.render(ctx)
    Spacer(v) => v.render(ctx)
    Padding(v) => v.render(ctx)
    Interact(v) => v.render(ctx)
  }
}

/// Measure any view
pub fn View::measure(self : View, constraints : Constraints) -> ViewSize {
  match self {
    Box(v) => v.measure(constraints)
    Text(v) => v.measure(constraints)
    Group(v) => v.measure(constraints)
    VStack(v) => v.measure(constraints)
    HStack(v) => v.measure(constraints)
    ZStack(v) => v.measure(constraints)
    Spacer(v) => v.measure(constraints)
    Padding(v) => v.measure(constraints)
    Interact(v) => v.measure(constraints)
  }
}

/// Box view component
pub struct BoxView {
  title : String?
  border : BorderStyle
  border_color : RGBA
  background : RGBA
  padding : Int
  justify : JustifyContent
  align : HorizontalAlignment
  children : Array[View]
}

/// Text view component
pub struct TextView {
  content : String
  style : TextStyle
  color : RGBA
  align : TextAlign
  wrap : TextWrap
}

/// Group view - invisible container
pub struct GroupView {
  children : Array[View]
}

/// Vertical stack layout
pub struct VStackView {
  spacing : Int
  alignment : HorizontalAlignment
  justify : JustifyContent
  children : Array[View]
}

/// Horizontal stack layout
pub struct HStackView {
  spacing : Int
  alignment : VerticalAlignment
  justify : JustifyContent
  children : Array[View]
}

/// Z-axis stack (overlapping)
pub struct ZStackView {
  alignment : Alignment
  children : Array[View]
}

/// Spacer - flexible space
pub struct SpacerView {
  min_length : Int
}

/// Padding wrapper
pub struct PaddingView {
  amount : Int
  child : View
}

/// Interactable wrapper for event handlers
pub struct InteractView {
  child : View
  on_click : (() -> Unit)?
  on_activate : (() -> Unit)?
}

pub fn InteractView::render(self : InteractView, ctx : RenderContext) -> Unit {
  self.child.render(ctx)
}

pub fn InteractView::measure(self : InteractView, constraints : Constraints) -> ViewSize {
  self.child.measure(constraints)
}

/// Alignment types
pub enum HorizontalAlignment {
  Leading
  Center
  Trailing
}

pub enum VerticalAlignment {
  Top
  Center
  Bottom
}

pub struct Alignment {
  horizontal : HorizontalAlignment
  vertical : VerticalAlignment
}

/// Smart constructors for clean API

pub fn box(
  title~ : String? = None,
  border~ : BorderStyle = BorderStyle::Single,
  border_color~ : RGBA = RGBA::white(),
  background~ : RGBA = RGBA::black(),
  padding~ : Int = 1,
  justify~ : JustifyContent = JustifyContent::Start,
  align~ : HorizontalAlignment = HorizontalAlignment::Leading,
  children~ : Array[View] = []
) -> View {
  View::Box({
    title,
    border,
    border_color,
    background,
    padding,
    justify,
    align,
    children
  })
}

pub fn text(
  content : String,
  style~ : TextStyle = TextStyle::None,
  color~ : RGBA = RGBA::white(),
  align~ : TextAlign = TextAlign::Left,
  wrap~ : TextWrap = TextWrap::None
) -> View {
  View::Text({
    content,
    style,
    color,
    align,
    wrap
  })
}

pub fn vstack(
  spacing~ : Int = 0,
  alignment~ : HorizontalAlignment = HorizontalAlignment::Leading,
  justify~ : JustifyContent = JustifyContent::Start,
  children : Array[View]
) -> View {
  View::VStack({
    spacing,
    alignment,
    justify,
    children
  })
}

pub fn hstack(
  spacing~ : Int = 0,
  alignment~ : VerticalAlignment = VerticalAlignment::Center,
  justify~ : JustifyContent = JustifyContent::Start,
  children : Array[View]
) -> View {
  View::HStack({
    spacing,
    alignment,
    justify,
    children
  })
}

pub fn zstack(
  alignment~ : Alignment = { horizontal: HorizontalAlignment::Center, vertical: VerticalAlignment::Center },
  children : Array[View]
) -> View {
  View::ZStack({
    alignment,
    children
  })
}

pub fn group(children : Array[View]) -> View {
  View::Group({ children })
}

pub fn spacer(min_length~ : Int = 0) -> View {
  View::Spacer({ min_length })
}

pub fn padding(amount : Int, child : View) -> View {
  View::Padding({ amount, child })
}

pub fn interact(
  child : View,
  on_click~ : (() -> Unit)? = None,
  on_activate~ : (() -> Unit)? = None
) -> View {
  View::Interact({ child, on_click, on_activate })
}
