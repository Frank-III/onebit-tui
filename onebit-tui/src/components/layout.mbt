///| Layout system using Yoga for OneBit-TUI
///| Components don't set width/height directly - they use flexbox properties

// Import Yoga types
typealias YogaNode = @wrapper.Node

// Layout properties that map to Yoga
pub struct LayoutProps {
  // Flex properties
  flex_grow : Double?
  flex_shrink : Double?
  flex_basis : Double?
  flex_direction : FlexDirection?
  flex_wrap : FlexWrap?
  
  // Alignment
  align_items : Align?
  align_self : Align?
  align_content : Align?
  justify_content : Justify?
  
  // Sizing - auto-calculated by Yoga
  width : SizeValue?
  height : SizeValue?
  min_width : SizeValue?
  min_height : SizeValue?
  max_width : SizeValue?
  max_height : SizeValue?
  
  // Spacing
  padding : EdgeValues?
  margin : EdgeValues?
  gap : Double?
  row_gap : Double?
  column_gap : Double?
  
  // Position
  position_type : PositionType?
  top : SizeValue?
  right : SizeValue?
  bottom : SizeValue?
  left : SizeValue?
}

// Size can be points, percentage, or auto
pub enum SizeValue {
  Points(Double)
  Percent(Double)
  Auto
}

// Edge values for padding/margin
pub struct EdgeValues {
  top : Double
  right : Double
  bottom : Double
  left : Double
}

pub fn EdgeValues::all(value : Double) -> EdgeValues {
  { top: value, right: value, bottom: value, left: value }
}

pub fn EdgeValues::symmetric(vertical : Double, horizontal : Double) -> EdgeValues {
  { top: vertical, right: horizontal, bottom: vertical, left: horizontal }
}

// Flex direction
pub enum FlexDirection {
  Row
  RowReverse
  Column
  ColumnReverse
}

// Flex wrap
pub enum FlexWrap {
  NoWrap
  Wrap
  WrapReverse
}

// Alignment
pub enum Align {
  Auto
  FlexStart
  Center
  FlexEnd
  Stretch
  Baseline
  SpaceBetween
  SpaceAround
  SpaceEvenly
}

// Justify content
pub enum Justify {
  FlexStart
  Center
  FlexEnd
  SpaceBetween
  SpaceAround
  SpaceEvenly
}

// Position type
pub enum PositionType {
  Static
  Relative
  Absolute
}

// Computed layout from Yoga
pub struct ComputedLayout {
  x : Double
  y : Double
  width : Double
  height : Double
}

// Base trait for layoutable components
pub trait Layoutable {
  // Get the Yoga node for this component
  yoga_node(Self) -> YogaNode
  
  // Apply layout props
  apply_layout(Self, LayoutProps) -> Unit
  
  // Get computed layout after Yoga calculation
  computed_layout(Self) -> ComputedLayout
  
  // Render at computed position
  render(Self, @core.App, ComputedLayout) -> Unit
}

// Layout context manages the Yoga tree
pub struct LayoutContext {
  config : @wrapper.Config
  root : YogaNode
  mut needs_layout : Bool
}

pub fn LayoutContext::new() -> LayoutContext {
  let config = @wrapper.Config::new()
  let root = @wrapper.Node::new_with_config(config)
  {
    config,
    root,
    needs_layout: true
  }
}

pub fn LayoutContext::calculate_layout(self : LayoutContext, width : Double, height : Double) -> Unit {
  if self.needs_layout {
    self.root.calculate_layout(width, height, @wrapper.Direction::LTR)
    self.needs_layout = false
  }
}

// Convert our enums to Yoga enums
fn to_yoga_flex_direction(dir : FlexDirection?) -> @wrapper.FlexDirection {
  match dir {
    Some(Row) => @wrapper.FlexDirection::Row
    Some(RowReverse) => @wrapper.FlexDirection::RowReverse
    Some(Column) => @wrapper.FlexDirection::Column
    Some(ColumnReverse) => @wrapper.FlexDirection::ColumnReverse
    None => @wrapper.FlexDirection::Column  // default
  }
}

fn to_yoga_align(align : Align?) -> @wrapper.Align {
  match align {
    Some(Auto) => @wrapper.Align::Auto
    Some(FlexStart) => @wrapper.Align::FlexStart
    Some(Center) => @wrapper.Align::Center
    Some(FlexEnd) => @wrapper.Align::FlexEnd
    Some(Stretch) => @wrapper.Align::Stretch
    Some(Baseline) => @wrapper.Align::Baseline
    Some(SpaceBetween) => @wrapper.Align::SpaceBetween
    Some(SpaceAround) => @wrapper.Align::SpaceAround
    Some(SpaceEvenly) => @wrapper.Align::SpaceEvenly
    None => @wrapper.Align::Auto
  }
}

fn to_yoga_justify(justify : Justify?) -> @wrapper.Justify {
  match justify {
    Some(FlexStart) => @wrapper.Justify::FlexStart
    Some(Center) => @wrapper.Justify::Center
    Some(FlexEnd) => @wrapper.Justify::FlexEnd
    Some(SpaceBetween) => @wrapper.Justify::SpaceBetween
    Some(SpaceAround) => @wrapper.Justify::SpaceAround
    Some(SpaceEvenly) => @wrapper.Justify::SpaceEvenly
    None => @wrapper.Justify::FlexStart
  }
}

// Apply layout props to a Yoga node
pub fn apply_layout_to_node(node : YogaNode, props : LayoutProps) -> Unit {
  // Flex properties
  match props.flex_grow {
    Some(value) => node.set_flex_grow(value.to_float())
    None => ()
  }
  
  match props.flex_shrink {
    Some(value) => node.set_flex_shrink(value.to_float())
    None => ()
  }
  
  match props.flex_direction {
    Some(dir) => node.set_flex_direction(to_yoga_flex_direction(Some(dir)))
    None => ()
  }
  
  // Alignment
  match props.align_items {
    Some(align) => node.set_align_items(to_yoga_align(Some(align)))
    None => ()
  }
  
  match props.justify_content {
    Some(justify) => node.set_justify_content(to_yoga_justify(Some(justify)))
    None => ()
  }
  
  // Sizing
  match props.width {
    Some(Points(value)) => node.set_width(value.to_float())
    Some(Percent(value)) => node.set_width_percent(value.to_float())
    Some(Auto) => node.set_width_auto()
    None => ()
  }
  
  match props.height {
    Some(Points(value)) => node.set_height(value.to_float())
    Some(Percent(value)) => node.set_height_percent(value.to_float())
    Some(Auto) => node.set_height_auto()
    None => ()
  }
  
  // Padding
  match props.padding {
    Some(edges) => {
      node.set_padding(@wrapper.Edge::Top, edges.top.to_float())
      node.set_padding(@wrapper.Edge::Right, edges.right.to_float())
      node.set_padding(@wrapper.Edge::Bottom, edges.bottom.to_float())
      node.set_padding(@wrapper.Edge::Left, edges.left.to_float())
    }
    None => ()
  }
  
  // Margin
  match props.margin {
    Some(edges) => {
      node.set_margin(@wrapper.Edge::Top, edges.top.to_float())
      node.set_margin(@wrapper.Edge::Right, edges.right.to_float())
      node.set_margin(@wrapper.Edge::Bottom, edges.bottom.to_float())
      node.set_margin(@wrapper.Edge::Left, edges.left.to_float())
    }
    None => ()
  }
  
  // Gap
  match props.gap {
    Some(value) => node.set_gap(@wrapper.Gutter::All, value.to_float())
    None => ()
  }
}