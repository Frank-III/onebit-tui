///| OneBit-TUI Main API

///| Clean, declarative API with Yoga layout support

///|
/// Terminal UI Application
pub struct TUI {
  renderer : @ffi.Renderer
  session : @ffi.TerminalSession
  mut buffer : @ffi.Buffer
  mut width : Int
  mut height : Int
  mut running : Bool
  // Yoga layout
  root : @wrapper.Node
  config : @wrapper.Config
  // UI tree
  mut ui_root : Element?
}

///|
/// UI Element - represents a component in the UI tree
pub struct Element {
  mut kind : ElementKind
  mut style : Style
  mut children : Array[Element]
  // Yoga node for layout
  yoga_node : @wrapper.Node
  // Callbacks
  mut on_click : ((Int, Int) -> Unit)?
  mut on_key : ((Char) -> Unit)?
}

///|
/// Types of UI elements
pub enum ElementKind {
  Box(BoxProps)
  Text(String)
  Button(String)
  List(Array[String], Ref[Int]) // items, selected_index
  Input(Ref[String]) // current text
}

///|
/// Box properties
pub struct BoxProps {
  mut title : String
  mut border : Bool
  mut border_color : Color
  mut background : Color
}

///|
/// Style properties (maps to Yoga)
pub struct Style {
  // Layout
  mut width : Size
  mut height : Size
  mut flex_direction : FlexDirection
  mut justify_content : Justify
  mut align_items : Align
  mut flex : Float
  mut padding : Spacing
  mut margin : Spacing
  mut gap : Float
  // Visual
  mut color : Color
  mut background : Color?
}

///|
/// Size can be fixed or flexible
pub(all) enum Size {
  Auto
  Pixels(Float)
  Percent(Float)
  Fill // flex: 1
}

///|
/// Spacing for padding/margin
pub struct Spacing {
  mut top : Float
  mut right : Float
  mut bottom : Float
  mut left : Float
}

///|
pub fn Spacing::all(value : Float) -> Spacing {
  Spacing::{ top: value, right: value, bottom: value, left: value }
}

///|
/// Flex direction
pub enum FlexDirection {
  Row
  Column
}

///|
/// Justify content
pub enum Justify {
  Start
  Center
  End
  SpaceBetween
  SpaceAround
  SpaceEvenly
}

///|
/// Align items
pub enum Align {
  Start
  Center
  End
  Stretch
}

///|
/// RGBA color
pub struct RGBA {
  r : Double
  g : Double
  b : Double
  a : Double
}

///|
/// Colors
pub(all) enum Color {
  Black
  Red
  Green
  Yellow
  Blue
  Magenta
  Cyan
  White
  Gray
  BrightRed
  BrightGreen
  BrightYellow
  BrightBlue
  BrightMagenta
  BrightCyan
  BrightWhite
  RGB(Double, Double, Double)
}

///|
/// Initialize TUI application (works without terminal session)
pub fn TUI::init() -> TUI? {
  let (width, height) = @ffi.get_terminal_size()
  match @ffi.Renderer::new(width, height) {
    None => None
    Some(renderer) => {
      // Try to create terminal session but don't fail if it doesn't work
      let session = @ffi.TerminalSession::new(
        raw_mode=false,
        mouse=false,
        resize_detection=false,
      )
      let config = @wrapper.Config::default()
      let root = @wrapper.Node::new_with_config(config)

      // Create a dummy session if real one failed
      let final_session = match session {
        Some(s) => s
        None =>
          @ffi.TerminalSession::{
            raw_mode: false,
            mouse_enabled: false,
            resize_handler: false,
          }
      }
      Some(TUI::{
        renderer,
        session: final_session,
        buffer: renderer.get_next_buffer(),
        width: width.reinterpret_as_int(),
        height: height.reinterpret_as_int(),
        running: true,
        root,
        config,
        ui_root: None,
      })
    }
  }
}

///|
/// Set the UI tree
pub fn TUI::set_ui(self : TUI, root : Element) -> Unit {
  self.ui_root = Some(root)
  // Setup Yoga tree
  self.setup_yoga_tree(root, self.root)
}

///|
fn TUI::setup_yoga_tree(
  self : TUI,
  element : Element,
  parent_node : @wrapper.Node,
) -> Unit {
  // Apply style to Yoga node
  self.apply_style_to_yoga(element.style, element.yoga_node)

  // Add to parent
  parent_node.add_child(element.yoga_node)

  // Process children
  for child in element.children {
    self.setup_yoga_tree(child, element.yoga_node)
  }
}

///|
fn TUI::apply_style_to_yoga(
  self : TUI,
  style : Style,
  node : @wrapper.Node,
) -> Unit {
  // Set dimensions
  match style.width {
    Auto => node.set_width_auto()
    Pixels(px) => node.set_width(@types.Value::point(px))
    Percent(pct) => node.set_width(@types.Value::percent(pct))
    Fill => {
      node.set_flex_grow(1.0)
      node.set_flex_shrink(1.0)
    }
  }
  match style.height {
    Auto => node.set_height_auto()
    Pixels(px) => node.set_height(@types.Value::point(px))
    Percent(pct) => node.set_height(@types.Value::percent(pct))
    Fill => {
      node.set_flex_grow(1.0)
      node.set_flex_shrink(1.0)
    }
  }

  // Set flex properties
  node.set_flex_direction(
    match style.flex_direction {
      Row => @types.FlexDirection::Row
      Column => @types.FlexDirection::Column
    },
  )
  node.set_justify_content(
    match style.justify_content {
      Start => @types.Justify::FlexStart
      Center => @types.Justify::Center
      End => @types.Justify::FlexEnd
      SpaceBetween => @types.Justify::SpaceBetween
      SpaceAround => @types.Justify::SpaceAround
      SpaceEvenly => @types.Justify::SpaceEvenly
    },
  )
  node.set_align_items(
    match style.align_items {
      Start => @types.Align::FlexStart
      Center => @types.Align::Center
      End => @types.Align::FlexEnd
      Stretch => @types.Align::Stretch
    },
  )

  // Set spacing
  node.set_padding(@types.Edge::Top, @types.Value::point(style.padding.top))
  node.set_padding(@types.Edge::Right, @types.Value::point(style.padding.right))
  node.set_padding(
    @types.Edge::Bottom,
    @types.Value::point(style.padding.bottom),
  )
  node.set_padding(@types.Edge::Left, @types.Value::point(style.padding.left))
  node.set_margin(@types.Edge::Top, @types.Value::point(style.margin.top))
  node.set_margin(@types.Edge::Right, @types.Value::point(style.margin.right))
  node.set_margin(@types.Edge::Bottom, @types.Value::point(style.margin.bottom))
  node.set_margin(@types.Edge::Left, @types.Value::point(style.margin.left))

  // TODO: Gap support not yet in Yoga wrapper
  // if style.gap > 0.0 {
  //   node.set_gap(@types.Gutter::All, style.gap)
  // }
}

///|
/// Run the main loop
pub fn TUI::run(self : TUI, on_update : (TUI) -> Unit) -> Unit {
  while self.running {
    // Clear buffer
    self.buffer.clear(0.0, 0.0, 0.0, 1.0)

    // Calculate layout if we have UI
    match self.ui_root {
      Some(root) => {
        // Calculate Yoga layout
        self.root.calculate_layout(
          self.width.to_double().to_float(),
          self.height.to_double().to_float(),
          @types.Direction::LTR,
        )

        // Render UI tree
        self.render_element(root, 0, 0)
      }
      None => ()
    }

    // User update callback
    on_update(self)

    // Render frame
    self.renderer.render()
    self.buffer = self.renderer.get_next_buffer()

    // Handle events
    self.handle_events()

    // Small delay
    @ffi.sleep_ms(16) // ~60 FPS
  }
}

///|
fn TUI::render_element(
  self : TUI,
  element : Element,
  offset_x : Int,
  offset_y : Int,
) -> Unit {
  // Get computed layout from Yoga
  let layout = element.yoga_node.get_layout()
  let x = (offset_x.to_double() + layout.left.to_double()).to_int()
  let y = (offset_y.to_double() + layout.top.to_double()).to_int()
  let width = layout.width.to_double().to_int()
  let height = layout.height.to_double().to_int()

  // Render based on element type
  match element.kind {
    Box(props) => {
      // Draw background
      match element.style.background {
        Some(bg_color) => {
          let (r, g, b) = color_to_rgb(bg_color)
          self.buffer.fill_rect(
            x.reinterpret_as_uint(),
            y.reinterpret_as_uint(),
            width.reinterpret_as_uint(),
            height.reinterpret_as_uint(),
            r,
            g,
            b,
            1.0,
          )
        }
        None => ()
      }

      // Draw border if needed
      if props.border {
        self.draw_border(x, y, width, height, props.border_color, props.title)
      }
    }
    Text(text) => {
      let (r, g, b) = color_to_rgb(element.style.color)
      self.buffer.draw_text(
        text,
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        fg_r=r,
        fg_g=g,
        fg_b=b,
      )
    }
    Button(label) => {
      // Draw button background
      let (bg_r, bg_g, bg_b) = color_to_rgb(Blue)
      self.buffer.fill_rect(
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        width.reinterpret_as_uint(),
        height.reinterpret_as_uint(),
        bg_r,
        bg_g,
        bg_b,
        1.0,
      )

      // Draw button text centered
      let text_x = x + (width - label.length()) / 2
      let text_y = y + height / 2
      self.buffer.draw_text(
        label,
        text_x.reinterpret_as_uint(),
        text_y.reinterpret_as_uint(),
        fg_r=1.0,
        fg_g=1.0,
        fg_b=1.0,
      )
    }
    List(items, selected) =>
      for i, item in items {
        let item_y = y + i
        if i == selected.val {
          // Highlight selected
          let (r, g, b) = color_to_rgb(Blue)
          self.buffer.fill_rect(
            x.reinterpret_as_uint(),
            item_y.reinterpret_as_uint(),
            width.reinterpret_as_uint(),
            1_U,
            r,
            g,
            b,
            1.0,
          )
          self.buffer.draw_text(
            "> " + item,
            x.reinterpret_as_uint(),
            item_y.reinterpret_as_uint(),
            fg_r=1.0,
            fg_g=1.0,
            fg_b=1.0,
          )
        } else {
          let (r, g, b) = color_to_rgb(element.style.color)
          self.buffer.draw_text(
            "  " + item,
            x.reinterpret_as_uint(),
            item_y.reinterpret_as_uint(),
            fg_r=r,
            fg_g=g,
            fg_b=b,
          )
        }
      }
    Input(text) => {
      // Draw input background
      let (bg_r, bg_g, bg_b) = color_to_rgb(Gray)
      self.buffer.fill_rect(
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        width.reinterpret_as_uint(),
        height.reinterpret_as_uint(),
        bg_r,
        bg_g,
        bg_b,
        0.2,
      )

      // Draw text
      self.buffer.draw_text(
        text.val,
        x.reinterpret_as_uint(),
        y.reinterpret_as_uint(),
        fg_r=1.0,
        fg_g=1.0,
        fg_b=1.0,
      )
    }
  }

  // Render children
  for child in element.children {
    self.render_element(child, x, y)
  }
}

///|
fn TUI::draw_border(
  self : TUI,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  color : Color,
  title : String,
) -> Unit {
  let (r, g, b) = color_to_rgb(color)
  let x_u = x.reinterpret_as_uint()
  let y_u = y.reinterpret_as_uint()
  let w_u = w.reinterpret_as_uint()
  let h_u = h.reinterpret_as_uint()

  // Top and bottom
  for i = 1; i < w - 1; i = i + 1 {
    self.buffer.draw_text(
      "─",
      x_u + i.reinterpret_as_uint(),
      y_u,
      fg_r=r,
      fg_g=g,
      fg_b=b,
    )
    self.buffer.draw_text(
      "─",
      x_u + i.reinterpret_as_uint(),
      y_u + h_u - 1_U,
      fg_r=r,
      fg_g=g,
      fg_b=b,
    )
  }

  // Left and right
  for i = 1; i < h - 1; i = i + 1 {
    self.buffer.draw_text(
      "│",
      x_u,
      y_u + i.reinterpret_as_uint(),
      fg_r=r,
      fg_g=g,
      fg_b=b,
    )
    self.buffer.draw_text(
      "│",
      x_u + w_u - 1_U,
      y_u + i.reinterpret_as_uint(),
      fg_r=r,
      fg_g=g,
      fg_b=b,
    )
  }

  // Corners
  self.buffer.draw_text("┌", x_u, y_u, fg_r=r, fg_g=g, fg_b=b)
  self.buffer.draw_text("┐", x_u + w_u - 1_U, y_u, fg_r=r, fg_g=g, fg_b=b)
  self.buffer.draw_text("└", x_u, y_u + h_u - 1_U, fg_r=r, fg_g=g, fg_b=b)
  self.buffer.draw_text(
    "┘",
    x_u + w_u - 1_U,
    y_u + h_u - 1_U,
    fg_r=r,
    fg_g=g,
    fg_b=b,
  )

  // Title
  if title != "" {
    self.buffer.draw_text(
      " " + title + " ",
      x_u + 2_U,
      y_u,
      fg_r=r,
      fg_g=g,
      fg_b=b,
    )
  }
}

///|
fn TUI::handle_events(self : TUI) -> Unit {
  match @ffi.poll_input_event() {
    @ffi.InputEvent::Key(key) =>
      match key {
        @ffi.KeyEvent::Char(113) | @ffi.KeyEvent::Escape => self.running = false
        _ => ()
      }
    @ffi.InputEvent::Resize(w, h) => {
      self.width = w.reinterpret_as_int()
      self.height = h.reinterpret_as_int()
      self.renderer.resize(w, h)
    }
    _ => ()
  }
}

///|
/// Stop the application
pub fn TUI::quit(self : TUI) -> Unit {
  self.running = false
}

///|
/// Cleanup resources
pub fn TUI::cleanup(self : TUI) -> Unit {
  self.session.cleanup()
  self.renderer.destroy()
}

// Helper functions

///|
pub fn color_to_rgb(color : Color) -> (Double, Double, Double) {
  match color {
    Black => (0.0, 0.0, 0.0)
    Red => (0.7, 0.0, 0.0)
    Green => (0.0, 0.7, 0.0)
    Yellow => (0.7, 0.7, 0.0)
    Blue => (0.0, 0.0, 0.7)
    Magenta => (0.7, 0.0, 0.7)
    Cyan => (0.0, 0.7, 0.7)
    White => (0.9, 0.9, 0.9)
    Gray => (0.5, 0.5, 0.5)
    BrightRed => (1.0, 0.0, 0.0)
    BrightGreen => (0.0, 1.0, 0.0)
    BrightYellow => (1.0, 1.0, 0.0)
    BrightBlue => (0.0, 0.0, 1.0)
    BrightMagenta => (1.0, 0.0, 1.0)
    BrightCyan => (0.0, 1.0, 1.0)
    BrightWhite => (1.0, 1.0, 1.0)
    RGB(r, g, b) => (r, g, b)
  }
}

// Builder functions for declarative UI

///|
/// Create a box element
pub fn box(
  title? : String = "",
  border? : Bool = false,
  children? : Array[Element] = [],
) -> Element {
  Element::{
    kind: Box(BoxProps::{
      title,
      border,
      border_color: White,
      background: Black,
    }),
    style: default_style(),
    children,
    yoga_node: @wrapper.Node::new(),
    on_click: None,
    on_key: None,
  }
}

///|
/// Create a text element
pub fn text(content : String) -> Element {
  Element::{
    kind: Text(content),
    style: default_style(),
    children: [],
    yoga_node: @wrapper.Node::new(),
    on_click: None,
    on_key: None,
  }
}

///|
/// Create a button element
pub fn button(label : String, on_click? : () -> Unit = fn() {  }) -> Element {
  Element::{
    kind: Button(label),
    style: default_style(),
    children: [],
    yoga_node: @wrapper.Node::new(),
    on_click: Some(fn(_, _) { on_click() }),
    on_key: None,
  }
}

///|
/// Create a list element
pub fn list(items : Array[String]) -> Element {
  Element::{
    kind: List(items, Ref::new(0)),
    style: default_style(),
    children: [],
    yoga_node: @wrapper.Node::new(),
    on_click: None,
    on_key: None,
  }
}

///|
/// Create an input element
pub fn input(initial? : String = "") -> Element {
  Element::{
    kind: Input(Ref::new(initial)),
    style: default_style(),
    children: [],
    yoga_node: @wrapper.Node::new(),
    on_click: None,
    on_key: None,
  }
}

///|
/// Style modifier functions (fluent API)
pub fn Element::with_style(self : Element, f : (Style) -> Unit) -> Element {
  f(self.style)
  self
}

///|
pub fn Element::width(self : Element, size : Size) -> Element {
  self.style.width = size
  self
}

///|
pub fn Element::height(self : Element, size : Size) -> Element {
  self.style.height = size
  self
}

///|
pub fn Element::flex(self : Element, value : Float) -> Element {
  self.style.flex = value
  self
}

///|
pub fn Element::padding(self : Element, value : Float) -> Element {
  self.style.padding = Spacing::all(value)
  self
}

///|
pub fn Element::margin(self : Element, value : Float) -> Element {
  self.style.margin = Spacing::all(value)
  self
}

///|
pub fn Element::gap(self : Element, value : Float) -> Element {
  self.style.gap = value
  self
}

///|
pub fn Element::row(self : Element) -> Element {
  self.style.flex_direction = Row
  self
}

///|
pub fn Element::column(self : Element) -> Element {
  self.style.flex_direction = Column
  self
}

///|
pub fn Element::center(self : Element) -> Element {
  self.style.justify_content = Center
  self.style.align_items = Center
  self
}

///|
pub fn Element::background(self : Element, color : Color) -> Element {
  self.style.background = Some(color)
  self
}

///|
pub fn Element::color(self : Element, color : Color) -> Element {
  self.style.color = color
  self
}

///|
fn default_style() -> Style {
  Style::{
    width: Auto,
    height: Auto,
    flex_direction: Column,
    justify_content: Start,
    align_items: Stretch,
    flex: 0.0,
    padding: Spacing::all(0.0),
    margin: Spacing::all(0.0),
    gap: 0.0,
    color: White,
    background: None,
  }
}
