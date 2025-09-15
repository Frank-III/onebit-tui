///| Event routing skeleton for OneBit-TUI

/// Minimal event loop that renders a view once and polls input briefly
pub fn run_basic_event_loop(view : View, width : Int, height : Int) -> Unit {
  match @ffi.Renderer::new(width.reinterpret_as_uint(), height.reinterpret_as_uint()) {
    Some(r) => {
      // Render once
      let buffer = r.get_next_buffer()
      let ctx = FFIRenderContext::{ buffer: buffer, bounds: Rect::new(0, 0, width, height) }
      view.render_ffi(ctx)
      r.render(force=true)

      // Try raw mode; ignore errors in non-TTY environments
      ignore(@ffi.set_terminal_raw_mode())
  let mut ticks = 0
  // Wait up to ~10s or until 'q'/ESC is pressed
  while ticks < 333 {
        if @ffi.is_input_available() {
          let b = @ffi.read_key_byte()
          if b == 113 || b == 27 { // 'q' or ESC
            break
          }
        }
        @ffi.sleep_ms(30)
        ticks = ticks + 1
      }
      ignore(@ffi.restore_terminal_mode())
      r.destroy()
    }
    None => ()
  }
}

/// Handler entry for interactable views
pub struct HandlerEntry {
  bounds : Rect
  on_click : (() -> Unit)?
  on_activate : (() -> Unit)?
}

/// Collect interactable handlers in painting order using Yoga-calculated bounds
pub fn collect_interact_handlers(view : View, bounds : Rect) -> Array[HandlerEntry] {
  match view {
    Interact(v) => [ HandlerEntry::{ bounds, on_click: v.on_click, on_activate: v.on_activate } ]
    Text(_) | Spacer(_) => []
    Group(g) => {
      let mut out = []
      for child in g.children {
        for it in collect_interact_handlers(child, bounds) { out.push(it) }
      }
      out
    }
    ZStack(z) => {
      let mut out = []
      for child in z.children {
        for it in collect_interact_handlers(child, bounds) { out.push(it) }
      }
      out
    }
    Padding(p) => {
      // Use Yoga to compute inner padded bounds for the single child
      let root = @wrapper.Node::new()
      root.set_width_points(bounds.width.to_double().to_float())
      root.set_height_points(bounds.height.to_double().to_float())
      root.set_padding_all(@types.Value::point(p.amount.to_double().to_float()))
      let child_node = @wrapper.Node::new()
      child_node.set_flex_grow(1.0)
      root.add_child(child_node)
      root.calculate_layout(bounds.width.to_double().to_float(), bounds.height.to_double().to_float(), @types.Direction::LTR)
      match root.get_child(0) {
        Some(n) => {
          let cb = Rect::new(
            bounds.x + n.layout_left().to_double().to_int(),
            bounds.y + n.layout_top().to_double().to_int(),
            n.layout_width().to_double().to_int(),
            n.layout_height().to_double().to_int(),
          )
          collect_interact_handlers(p.child, cb)
        }
        None => []
      }
    }
    VStack(vs) => {
      let root = @wrapper.Node::new()
      root.set_flex_direction(@types.FlexDirection::Column)
      // Main-axis justify
      let j = match vs.justify {
        JustifyContent::Start => @types.Justify::FlexStart
        JustifyContent::Center => @types.Justify::Center
        JustifyContent::End => @types.Justify::FlexEnd
        JustifyContent::SpaceBetween => @types.Justify::SpaceBetween
        JustifyContent::SpaceAround => @types.Justify::SpaceAround
        JustifyContent::SpaceEvenly => @types.Justify::SpaceEvenly
      }
      root.set_justify_content(j)
      // Cross-axis from HorizontalAlignment
      let ai = match vs.alignment {
        HorizontalAlignment::Leading => @types.Align::FlexStart
        HorizontalAlignment::Center => @types.Align::Center
        HorizontalAlignment::Trailing => @types.Align::FlexEnd
      }
      root.set_align_items(ai)
      root.set_width_points(bounds.width.to_double().to_float())
      root.set_height_points(bounds.height.to_double().to_float())
      for i = 0; i < vs.children.length(); i = i + 1 {
        let n = @wrapper.Node::new()
        n.set_flex_grow(1.0)
        if i < vs.children.length() - 1 {
          n.set_margin(@types.Edge::Bottom, @types.Value::point(vs.spacing.to_double().to_float()))
        }
        root.add_child(n)
      }
      root.calculate_layout(bounds.width.to_double().to_float(), bounds.height.to_double().to_float(), @types.Direction::LTR)
      let mut out = []
      for i = 0; i < vs.children.length(); i = i + 1 {
        match root.get_child(i) {
          Some(n) => {
            let cb = Rect::new(
              bounds.x + n.layout_left().to_double().to_int(),
              bounds.y + n.layout_top().to_double().to_int(),
              n.layout_width().to_double().to_int(),
              n.layout_height().to_double().to_int(),
            )
            for it in collect_interact_handlers(vs.children[i], cb) { out.push(it) }
          }
          None => ()
        }
      }
      out
    }
    HStack(hs) => {
      let root = @wrapper.Node::new()
      root.set_flex_direction(@types.FlexDirection::Row)
      let jh = match hs.justify {
        JustifyContent::Start => @types.Justify::FlexStart
        JustifyContent::Center => @types.Justify::Center
        JustifyContent::End => @types.Justify::FlexEnd
        JustifyContent::SpaceBetween => @types.Justify::SpaceBetween
        JustifyContent::SpaceAround => @types.Justify::SpaceAround
        JustifyContent::SpaceEvenly => @types.Justify::SpaceEvenly
      }
      root.set_justify_content(jh)
      let ai = match hs.alignment {
        VerticalAlignment::Top => @types.Align::FlexStart
        VerticalAlignment::Center => @types.Align::Center
        VerticalAlignment::Bottom => @types.Align::FlexEnd
      }
      root.set_align_items(ai)
      root.set_width_points(bounds.width.to_double().to_float())
      root.set_height_points(bounds.height.to_double().to_float())
      for i = 0; i < hs.children.length(); i = i + 1 {
        let n = @wrapper.Node::new()
        n.set_flex_grow(1.0)
        if i < hs.children.length() - 1 {
          n.set_margin(@types.Edge::Right, @types.Value::point(hs.spacing.to_double().to_float()))
        }
        root.add_child(n)
      }
      root.calculate_layout(bounds.width.to_double().to_float(), bounds.height.to_double().to_float(), @types.Direction::LTR)
      let mut out = []
      for i = 0; i < hs.children.length(); i = i + 1 {
        match root.get_child(i) {
          Some(n) => {
            let cb = Rect::new(
              bounds.x + n.layout_left().to_double().to_int(),
              bounds.y + n.layout_top().to_double().to_int(),
              n.layout_width().to_double().to_int(),
              n.layout_height().to_double().to_int(),
            )
            for it in collect_interact_handlers(hs.children[i], cb) { out.push(it) }
          }
          None => ()
        }
      }
      out
    }
    Box(bx) => {
      // Compute inner area (subtract border/title) and use padding via Yoga
      let border_width = if bx.border == BorderStyle::None { 0 } else { 1 }
      let title_height = match bx.title {
        Some(_) => 1
        None => 0
      }
      let inner_x = bounds.x + border_width
      let inner_y = bounds.y + border_width + title_height
      let inner_w = bounds.width - border_width * 2
      let inner_h = bounds.height - border_width * 2 - title_height
      if bx.children.length() == 0 { return [] }
      let root = @wrapper.Node::new()
      root.set_flex_direction(@types.FlexDirection::Column)
      let jb = match bx.justify {
        JustifyContent::Start => @types.Justify::FlexStart
        JustifyContent::Center => @types.Justify::Center
        JustifyContent::End => @types.Justify::FlexEnd
        JustifyContent::SpaceBetween => @types.Justify::SpaceBetween
        JustifyContent::SpaceAround => @types.Justify::SpaceAround
        JustifyContent::SpaceEvenly => @types.Justify::SpaceEvenly
      }
      root.set_justify_content(jb)
      let ai = match bx.align {
        HorizontalAlignment::Leading => @types.Align::FlexStart
        HorizontalAlignment::Center => @types.Align::Center
        HorizontalAlignment::Trailing => @types.Align::FlexEnd
      }
      root.set_align_items(ai)
      root.set_width_points(inner_w.to_double().to_float())
      root.set_height_points(inner_h.to_double().to_float())
      root.set_padding_all(@types.Value::point(bx.padding.to_double().to_float()))
      for _ in bx.children {
        let n = @wrapper.Node::new()
        n.set_flex_grow(1.0)
        root.add_child(n)
      }
      root.calculate_layout(inner_w.to_double().to_float(), inner_h.to_double().to_float(), @types.Direction::LTR)
      let mut out = []
      for i = 0; i < bx.children.length(); i = i + 1 {
        match root.get_child(i) {
          Some(n) => {
            let cb = Rect::new(
              inner_x + n.layout_left().to_double().to_int(),
              inner_y + n.layout_top().to_double().to_int(),
              n.layout_width().to_double().to_int(),
              n.layout_height().to_double().to_int(),
            )
            for it in collect_interact_handlers(bx.children[i], cb) { out.push(it) }
          }
          None => ()
        }
      }
      out
    }
  }
}

/// Dispatch a mouse click; returns true if a handler ran
pub fn dispatch_mouse_click(view : View, bounds : Rect, x : Int, y : Int) -> Bool {
  let entries = collect_interact_handlers(view, bounds)
  if entries.length() == 0 { return false }
  let mut items = []
  for e in entries { items.push(LayoutItem::{ bounds: e.bounds }) }
  match hit_test(x, y, items) {
    Some(idx) => {
      match entries[idx].on_click {
        Some(f) => { f(); true }
        None => false
      }
    }
    None => false
  }
}

/// Dispatch activation for the focused index; returns true if a handler ran
pub fn dispatch_activate(view : View, bounds : Rect, focus_index : Int) -> Bool {
  let entries = collect_interact_handlers(view, bounds)
  if focus_index < 0 || focus_index >= entries.length() { return false }
  match entries[focus_index].on_activate {
    Some(f) => { f(); true }
    None => false
  }
}
