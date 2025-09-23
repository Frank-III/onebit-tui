///| Event Dispatch - Routes events to appropriate View handlers

///|
/// Find which view should handle a mouse event based on position
pub fn find_view_at_position(
  view : @view.View,
  x : Int,
  y : Int,
  current_x : Int,
  current_y : Int,
  layout : @yoga.Node,
) -> @view.View? {
  // Get the computed layout bounds
  let left = layout.layout_left().to_int() + current_x
  let top = layout.layout_top().to_int() + current_y
  let width = layout.layout_width().to_int()
  let height = layout.layout_height().to_int()

  // Check if position is within this view's bounds
  if x >= left && x < left + width && y >= top && y < top + height {
    // Check children first (they render on top)
    let children = view.children
    let child_count = layout.get_child_count()
    for i = child_count - 1; i >= 0; i = i - 1 {
      let child_layout = layout.get_child(i)
      match child_layout {
        Some(cl) =>
          if i < children.length() {
            match find_view_at_position(children[i], x, y, left, top, cl) {
              Some(found) => return Some(found)
              None => ()
            }
          }
        None => ()
      }
    }

    // If no child handles it, return this view if it has a click handler
    match view.click_handler {
      Some(_) => Some(view)
      None => None
    }
  } else {
    None
  }
}

///|
/// Dispatch keyboard event to focused view
pub fn dispatch_key_event(
  view : @view.View,
  event : @ffi.KeyEvent,
  focused_view_id : Int?,
) -> Bool {
  // First check if this view is focused
  match (view.view_id, focused_view_id) {
    (Some(id), Some(focused_id)) if id == focused_id =>
      match view.key_handler {
        Some(handler) => return handler(event)
        None => ()
      }
    _ => ()
  }

  // Then check children
  for child in view.children {
    if dispatch_key_event(child, event, focused_view_id) {
      return true
    }
  }
  false
}

///|
/// Dispatch mouse click to appropriate view
pub fn dispatch_click(
  view : @view.View,
  x : Int,
  y : Int,
  layout : @yoga.Node,
) -> Bool {
  match find_view_at_position(view, x, y, 0, 0, layout) {
    Some(target_view) =>
      match target_view.click_handler {
        Some(handler) => {
          handler(x, y)
          true
        }
        None => false
      }
    None => false
  }
}

///|
/// Set focus state on a view by ID
pub fn set_view_focused(
  view : @view.View,
  view_id : Int?,
  focused : Bool,
) -> Bool {
  match (view.view_id, view_id) {
    (Some(vid), Some(target_id)) if vid == target_id => {
      view.set_focused(focused)
      return true
    }
    _ => ()
  }

  // Check children
  for child in view.children {
    if set_view_focused(child, view_id, focused) {
      return true
    }
  }
  false
}

///|
/// Clear all focus states in view tree
pub fn clear_all_focus(view : @view.View) -> Unit {
  view.set_focused(false)
  for child in view.children {
    clear_all_focus(child)
  }
}

///|
/// Find next focusable view (for Tab navigation)
pub fn find_next_focusable(
  view : @view.View,
  current_id : Int?,
  found_current : Ref[Bool],
) -> Int? {
  // If this view is focusable and we've passed the current
  if view.is_focusable && found_current.val {
    return view.view_id
  }

  // Check if this is the current focused view
  match (view.view_id, current_id) {
    (Some(id), Some(curr)) if id == curr => found_current.val = true
    _ => ()
  }

  // Check children
  for child in view.children {
    match find_next_focusable(child, current_id, found_current) {
      Some(id) => return Some(id)
      None => ()
    }
  }

  // If we haven't found anything and this is focusable, return it (wrap around)
  if view.is_focusable && current_id is None {
    return view.view_id
  }
  None
}

///|
/// Collect all focusable view IDs in pre-order traversal
pub fn collect_focusable_ids(view : @view.View) -> Array[Int] {
  let ids : Array[Int] = []
  collect_focusable_ids_rec(view, ids)
  ids
}

///|
fn collect_focusable_ids_rec(view : @view.View, out : Array[Int]) -> Unit {
  if view.is_focusable {
    match view.view_id {
      Some(id) => out.push(id)
      None => ()
    }
  }
  for child in view.children {
    collect_focusable_ids_rec(child, out)
  }
}
