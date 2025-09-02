///| Yoga-based layout calculation utilities

/// A flattened layout item representing a leaf view's bounds
pub struct LayoutItem {
  bounds : Rect
}

/// Compute flattened leaf bounds for a view tree using Yoga where applicable
pub fn flatten_layout(view : View, bounds : Rect) -> Array[LayoutItem] {
  match view {
    Interact(_) => [ { bounds } ]
    Text(_) => [ { bounds } ]
    Spacer(_) => [ { bounds } ]
    Group(v) => {
      let mut out = []
      for child in v.children {
        for it in flatten_layout(child, bounds) { out.push(it) }
      }
      out
    }
    ZStack(v) => {
      let mut out = []
      for child in v.children {
        for it in flatten_layout(child, bounds) { out.push(it) }
      }
      out
    }
    Padding(v) => {
      // Use Yoga to compute child padded area
      let root = @wrapper.Node::new()
      root.set_width_points(bounds.width.to_double().to_float())
      root.set_height_points(bounds.height.to_double().to_float())
      root.set_padding_all(@types.Value::point(v.amount.to_double().to_float()))
      let child_node = @wrapper.Node::new()
      child_node.set_flex_grow(1.0)
      root.add_child(child_node)
      root.calculate_layout(bounds.width.to_double().to_float(), bounds.height.to_double().to_float(), @types.Direction::LTR)
      match root.get_child(0) {
        Some(n) => {
          let cb = Rect::new(
            bounds.x + n.layout_left().to_int(),
            bounds.y + n.layout_top().to_int(),
            n.layout_width().to_int(),
            n.layout_height().to_int(),
          )
          flatten_layout(v.child, cb)
        }
        None => []
      }
    }
    VStack(v) => {
      let root = @wrapper.Node::new()
      root.set_flex_direction(@types.FlexDirection::Column)
      // Map main-axis justify
      let j = match v.justify {
        JustifyContent::Start => @types.Justify::FlexStart
        JustifyContent::Center => @types.Justify::Center
        JustifyContent::End => @types.Justify::FlexEnd
        JustifyContent::SpaceBetween => @types.Justify::SpaceBetween
        JustifyContent::SpaceAround => @types.Justify::SpaceAround
        JustifyContent::SpaceEvenly => @types.Justify::SpaceEvenly
      }
      root.set_justify_content(j)
      root.set_width_points(bounds.width.to_double().to_float())
      root.set_height_points(bounds.height.to_double().to_float())
      for i = 0; i < v.children.length(); i = i + 1 {
        let n = @wrapper.Node::new()
        n.set_flex_grow(1.0)
        if i < v.children.length() - 1 {
          n.set_margin(@types.Edge::Bottom, @types.Value::point(v.spacing.to_double().to_float()))
        }
        root.add_child(n)
      }
      root.calculate_layout(bounds.width.to_double().to_float(), bounds.height.to_double().to_float(), @types.Direction::LTR)
      let mut out = []
      for i = 0; i < v.children.length(); i = i + 1 {
        match root.get_child(i) {
          Some(n) => {
            let cb = Rect::new(
              bounds.x + n.layout_left().to_int(),
              bounds.y + n.layout_top().to_int(),
              n.layout_width().to_int(),
              n.layout_height().to_int(),
            )
            for it in flatten_layout(v.children[i], cb) { out.push(it) }
          }
          None => ()
        }
      }
      out
    }
    HStack(v) => {
      let root = @wrapper.Node::new()
      root.set_flex_direction(@types.FlexDirection::Row)
      let jh = match v.justify {
        JustifyContent::Start => @types.Justify::FlexStart
        JustifyContent::Center => @types.Justify::Center
        JustifyContent::End => @types.Justify::FlexEnd
        JustifyContent::SpaceBetween => @types.Justify::SpaceBetween
        JustifyContent::SpaceAround => @types.Justify::SpaceAround
        JustifyContent::SpaceEvenly => @types.Justify::SpaceEvenly
      }
      root.set_justify_content(jh)
      root.set_width_points(bounds.width.to_double().to_float())
      root.set_height_points(bounds.height.to_double().to_float())
      for i = 0; i < v.children.length(); i = i + 1 {
        let n = @wrapper.Node::new()
        n.set_flex_grow(1.0)
        if i < v.children.length() - 1 {
          n.set_margin(@types.Edge::Right, @types.Value::point(v.spacing.to_double().to_float()))
        }
        root.add_child(n)
      }
      root.calculate_layout(bounds.width.to_double().to_float(), bounds.height.to_double().to_float(), @types.Direction::LTR)
      let mut out = []
      for i = 0; i < v.children.length(); i = i + 1 {
        match root.get_child(i) {
          Some(n) => {
            let cb = Rect::new(
              bounds.x + n.layout_left().to_int(),
              bounds.y + n.layout_top().to_int(),
              n.layout_width().to_int(),
              n.layout_height().to_int(),
            )
            for it in flatten_layout(v.children[i], cb) { out.push(it) }
          }
          None => ()
        }
      }
      out
    }
    Box(v) => {
      // Inner area subtract border and title
      let border_width = if v.border == BorderStyle::None { 0 } else { 1 }
      let title_height = match v.title {
        Some(_) => 1
        None => 0
      }
      let inner_x = bounds.x + border_width
      let inner_y = bounds.y + border_width + title_height
      let inner_w = bounds.width - border_width * 2
      let inner_h = bounds.height - border_width * 2 - title_height
      if v.children.length() == 0 {
        return []
      }
      let root = @wrapper.Node::new()
      root.set_flex_direction(@types.FlexDirection::Column)
      let jb = match v.justify {
        JustifyContent::Start => @types.Justify::FlexStart
        JustifyContent::Center => @types.Justify::Center
        JustifyContent::End => @types.Justify::FlexEnd
        JustifyContent::SpaceBetween => @types.Justify::SpaceBetween
        JustifyContent::SpaceAround => @types.Justify::SpaceAround
        JustifyContent::SpaceEvenly => @types.Justify::SpaceEvenly
      }
      root.set_justify_content(jb)
      // Cross-axis alignment from Box.align
      let ai = match v.align {
        HorizontalAlignment::Leading => @types.Align::FlexStart
        HorizontalAlignment::Center => @types.Align::Center
        HorizontalAlignment::Trailing => @types.Align::FlexEnd
      }
      root.set_align_items(ai)
      root.set_width_points(inner_w.to_double().to_float())
      root.set_height_points(inner_h.to_double().to_float())
      root.set_padding_all(@types.Value::point(v.padding.to_double().to_float()))
      for _ in v.children {
        let n = @wrapper.Node::new()
        n.set_flex_grow(1.0)
        root.add_child(n)
      }
      root.calculate_layout(inner_w.to_double().to_float(), inner_h.to_double().to_float(), @types.Direction::LTR)
      let mut out = []
      for i = 0; i < v.children.length(); i = i + 1 {
        match root.get_child(i) {
          Some(n) => {
            let cb = Rect::new(
              inner_x + n.layout_left().to_int(),
              inner_y + n.layout_top().to_int(),
              n.layout_width().to_int(),
              n.layout_height().to_int(),
            )
            for it in flatten_layout(v.children[i], cb) { out.push(it) }
          }
          None => ()
        }
      }
      out
    }
  }
}

/// Return the topmost layout item index at (x,y), or None if not found
pub fn hit_test(x : Int, y : Int, items : Array[LayoutItem]) -> Int? {
  // Iterate from end to start to respect draw order (last on top)
  if items.length() == 0 { return None }
  let mut i = items.length() - 1
  while true {
    let b = items[i].bounds
    if x >= b.x && x < b.x + b.width && y >= b.y && y < b.y + b.height {
      return Some(i)
    }
    if i == 0 { break }
    i = i - 1
  }
  None
}
