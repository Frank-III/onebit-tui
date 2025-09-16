///| Rendering helpers to integrate View + App without cyclic deps

pub fn render_view(app : @core.App, root : View) -> Unit {
  let (w, h) = app.dimensions()
  root.calculate_layout(w.to_double(), h.to_double())
  let buf = app.get_buffer()
  root.render(buf)
  // Register hit regions for clickable views
  register_hit_regions(app, root, 0, 0)
  app.render()
}

/// Render view and draw a focus ring around the focused view (if any)
pub fn render_view_with_focus(app : @core.App, root : View, focused_id : Int) -> Unit {
  let (w, h) = app.dimensions()
  root.calculate_layout(w.to_double(), h.to_double())
  let buf = app.get_buffer()
  root.render(buf)
  if focused_id > 0 {
    match find_view_rect(root, focused_id, 0, 0) {
      Some((x, y, ww, hh)) => draw_focus_ring(buf, x, y, ww, hh)
      None => ()
    }
  }
  register_hit_regions(app, root, 0, 0)
  app.render()
}

fn draw_focus_ring(buf : @ffi.Buffer, x : Int, y : Int, w : Int, h : Int) -> Unit {
  // Draw a focus ring using colored rectangles
  // Make it thicker and more visible
  let (r, g, b) = @core.color_to_rgb(@core.Color::BrightCyan)
  
  // Top border (2 pixels thick for visibility)
  buf.fill_rect(x.reinterpret_as_uint(), y.reinterpret_as_uint(), w.reinterpret_as_uint(), 1, r, g, b, 0.8)
  if h > 1 {
    buf.fill_rect(x.reinterpret_as_uint(), (y + 1).reinterpret_as_uint(), w.reinterpret_as_uint(), 1, r, g, b, 0.4)
  }
  
  // Bottom border
  if h > 2 {
    buf.fill_rect(x.reinterpret_as_uint(), (y + h - 2).reinterpret_as_uint(), w.reinterpret_as_uint(), 1, r, g, b, 0.4)
  }
  buf.fill_rect(x.reinterpret_as_uint(), (y + h - 1).reinterpret_as_uint(), w.reinterpret_as_uint(), 1, r, g, b, 0.8)
  
  // Left border
  buf.fill_rect(x.reinterpret_as_uint(), y.reinterpret_as_uint(), 1, h.reinterpret_as_uint(), r, g, b, 0.8)
  if w > 1 {
    buf.fill_rect((x + 1).reinterpret_as_uint(), y.reinterpret_as_uint(), 1, h.reinterpret_as_uint(), r, g, b, 0.4)
  }
  
  // Right border  
  if w > 2 {
    buf.fill_rect((x + w - 2).reinterpret_as_uint(), y.reinterpret_as_uint(), 1, h.reinterpret_as_uint(), r, g, b, 0.4)
  }
  buf.fill_rect((x + w - 1).reinterpret_as_uint(), y.reinterpret_as_uint(), 1, h.reinterpret_as_uint(), r, g, b, 0.8)
}

fn find_view_rect(view : View, target_id : Int, parent_x : Int, parent_y : Int) -> (Int, Int, Int, Int)? {
  match view.computed {
    Some(layout) => {
      let x = parent_x + layout.x.to_int()
      let y = parent_y + layout.y.to_int()
      let w = layout.width.to_int()
      let h = layout.height.to_int()
      if view.id == target_id {
        return Some((x, y, w, h))
      }
      for i = 0; i < view.children.length(); i = i + 1 {
        match find_view_rect(view.children[i], target_id, x, y) {
          Some(rect) => return Some(rect)
          None => ()
        }
      }
      None
    }
    None => None
  }
}

let view_id : Ref[Int] = Ref::new(1)

fn register_hit_regions(app : @core.App, view : View, parent_x : Int, parent_y : Int) -> Unit {
  match view.computed {
    Some(layout) => {
      let abs_x = parent_x + layout.x.to_int()
      let abs_y = parent_y + layout.y.to_int()
      let w = layout.width.to_int()
      let h = layout.height.to_int()
      // Assign an id if this view participates in interaction (click, key, focus)
      let needs_id = match (view.on_click, view.on_key, view.focusable) {
        (Some(_), _, _) => true
        (_, Some(_), _) => true
        (_, _, true) => true
        _ => false
      }
      if needs_id {
        if view.id == 0 {
          view.id = view_id.val
          view_id.val = view_id.val + 1
        }
      }
      // Add to hit grid if clickable or focusable (to allow focusing via mouse)
      match (view.on_click, view.focusable) {
        (Some(_), _) => app.get_renderer().add_hit_region(abs_x, abs_y, w, h, view.id)
        (None, true) => app.get_renderer().add_hit_region(abs_x, abs_y, w, h, view.id)
        _ => ()
      }
      // Children
      for i = 0; i < view.children.length(); i = i + 1 {
        register_hit_regions(app, view.children[i], abs_x, abs_y)
      }
    }
    None => ()
  }
}

/// Dispatch a click: resolves hit id and invokes handler
pub fn dispatch_click(app : @core.App, root : View, x : Int, y : Int) -> Unit {
  let id = app.get_renderer().check_hit(x, y)
  if id <= 0 { return }
  invoke_click(root, id, 0, 0, x, y) |> ignore
}

fn invoke_click(view : View, target_id : Int, parent_x : Int, parent_y : Int, click_x : Int, click_y : Int) -> Bool {
  match view.computed {
    Some(layout) => {
      let abs_x = parent_x + layout.x.to_int()
      let abs_y = parent_y + layout.y.to_int()
      if view.id == target_id {
        match view.on_click {
          Some(cb) => { cb(click_x - abs_x, click_y - abs_y); return true }
          None => ()
        }
      }
      for i = 0; i < view.children.length(); i = i + 1 {
        if invoke_click(view.children[i], target_id, abs_x, abs_y, click_x, click_y) { return true }
      }
      false
    }
    None => false
  }
}

/// Collect ids of focusable views in paint order
pub fn collect_focusable(root : View) -> Array[Int] {
  let ids : Array[Int] = []
  collect_focusable_inner(root, ids)
  ids
}

fn collect_focusable_inner(view : View, ids : Array[Int]) -> Unit {
  // Ensure id assignment if focusable or key handler exists
  let has_key = match view.on_key {
    Some(_) => true
    None => false
  }
  let interactive = view.focusable || has_key
  if interactive {
    if view.id == 0 {
      view.id = view_id.val
      view_id.val = view_id.val + 1
    }
    ids.push(view.id)
  }
  for i = 0; i < view.children.length(); i = i + 1 {
    collect_focusable_inner(view.children[i], ids)
  }
}

/// Find the focus trap container for a given view id
fn find_focus_trap(view : View, target_id : Int) -> View? {
  if view.is_focus_trap && contains_id(view, target_id) {
    return Some(view)
  }
  for i = 0; i < view.children.length(); i = i + 1 {
    match find_focus_trap(view.children[i], target_id) {
      Some(trap) => return Some(trap)
      None => continue
    }
  }
  None
}

/// Check if a view tree contains a specific id
fn contains_id(view : View, target_id : Int) -> Bool {
  if view.id == target_id { return true }
  for i = 0; i < view.children.length(); i = i + 1 {
    if contains_id(view.children[i], target_id) { return true }
  }
  false
}

/// Cycle focus to next focusable view (wrap-around, respecting focus traps)
pub fn focus_next(root : View, focused_id : Ref[Int]) -> Unit {
  // Check if we're in a focus trap
  let trap_opt = find_focus_trap(root, focused_id.val)
  let search_root = match trap_opt {
    Some(trap) => trap
    None => root
  }
  
  let ids = collect_focusable(search_root)
  if ids.length() == 0 { return }
  let mut idx = -1
  for i = 0; i < ids.length(); i = i + 1 {
    if ids[i] == focused_id.val { idx = i; break }
  }
  let next = if idx < 0 { ids[0] } else { ids[(idx + 1) % ids.length()] }
  focused_id.val = next
}

/// Cycle focus to previous focusable view (wrap-around, respecting focus traps)
pub fn focus_previous(root : View, focused_id : Ref[Int]) -> Unit {
  // Check if we're in a focus trap
  let trap_opt = find_focus_trap(root, focused_id.val)
  let search_root = match trap_opt {
    Some(trap) => trap
    None => root
  }
  
  let ids = collect_focusable(search_root)
  if ids.length() == 0 { return }
  let mut idx = -1
  for i = 0; i < ids.length(); i = i + 1 {
    if ids[i] == focused_id.val { idx = i; break }
  }
  let prev = if idx <= 0 { ids[ids.length() - 1] } else { ids[idx - 1] }
  focused_id.val = prev
}

/// Dispatch a key event to the focused view
pub fn dispatch_key(root : View, focused_id : Int, key : @ffi.KeyEvent) -> Bool {
  invoke_key(root, focused_id, key)
}

fn invoke_key(view : View, target_id : Int, key : @ffi.KeyEvent) -> Bool {
  if view.id == target_id {
    match view.on_key {
      Some(cb) => return cb(key)
      None => ()
    }
  }
  for i = 0; i < view.children.length(); i = i + 1 {
    if invoke_key(view.children[i], target_id, key) { return true }
  }
  false
}

/// Adjust scroll_y by delta for a view id (returns updated root)
pub fn adjust_view_scroll(root : View, target_id : Int, delta : Int) -> View {
  if root.id == target_id {
    let new_y = root.scroll_y + delta
    return root.scroll(if new_y < 0 { 0 } else { new_y })
  }
  for i = 0; i < root.children.length(); i = i + 1 {
    root.children[i] = adjust_view_scroll(root.children[i], target_id, delta)
  }
  root
}

/// Set scroll_y of a specific view by id (returns updated root)
pub fn set_view_scroll(root : View, target_id : Int, scroll_y : Int) -> View {
  if root.id == target_id {
    return root.scroll(scroll_y)
  }
  for i = 0; i < root.children.length(); i = i + 1 {
    root.children[i] = set_view_scroll(root.children[i], target_id, scroll_y)
  }
  root
}

fn invoke_key_mod(view : View, target_id : Int, key : @ffi.KeyEvent, mods : @ffi.KeyModifiers) -> Bool {
  if view.id == target_id {
    match view.on_key_mod {
      Some(cb) => return cb(key, mods)
      None => ()
    }
  }
  for i = 0; i < view.children.length(); i = i + 1 {
    if invoke_key_mod(view.children[i], target_id, key, mods) { return true }
  }
  false
}

/// Handle a single input event for basic focus navigation and key dispatch
pub fn handle_input_event(root : View, focused_id : Ref[Int], event : @ffi.InputEvent) -> Bool {
  match event {
    @ffi.InputEvent::Key(key) => {
      match key {
        @ffi.KeyEvent::Tab => { focus_next(root, focused_id); true }
        _ => dispatch_key(root, focused_id.val, key)
      }
    }
    @ffi.InputEvent::KeyMod(key, mods) => {
      // Try modifier-aware handler first; fall back to base key handler
      match key {
        @ffi.KeyEvent::Tab => { 
          // Shift+Tab goes backwards
          if mods.shift {
            focus_previous(root, focused_id)
          } else {
            focus_next(root, focused_id)
          }
          true
        }
        _ => {
          if invoke_key_mod(root, focused_id.val, key, mods) { true }
          else { dispatch_key(root, focused_id.val, key) }
        }
      }
    }
    _ => false
  }
}

/// Find first interactive view id (has key handler or is scrollable or focusable)
pub fn find_first_interactive_id(view : View) -> Int {
  // Pre-order search
  if interactive(view) { return ensure_id(view) }
  for i = 0; i < view.children.length(); i = i + 1 {
    let id = find_first_interactive_id(view.children[i])
    if id > 0 { return id }
  }
  0
}

fn interactive(view : View) -> Bool {
  match (view.on_key, view.on_key_mod, view.scrollable, view.focusable) {
    (Some(_), _, _, _) => true
    (_, Some(_), _, _) => true
    (_, _, true, _) => true
    (_, _, _, true) => true
    _ => false
  }
}

fn ensure_id(view : View) -> Int {
  if view.id == 0 {
    view.id = view_id.val
    view_id.val = view_id.val + 1
  }
  view.id
}

///| Render a scrollable content inside a container view.
///| Assumes both views were already laid out and rendered; this will re-render
///| the content clipped to the container, offset by scroll_y.
pub fn render_scroll_content(
  app : @core.App,
  container : View,
  content : View,
  scroll_y : Int,
) -> Unit {
  match (container.computed, content.computed) {
    (Some(c), Some(_)) => {
      let buf = app.get_buffer()
      // Clip to container bounds if available, then render with offset
      let cx = c.x.to_int()
      let cy = c.y.to_int()
      let cw = c.width.to_int()
      let ch = c.height.to_int()
      buf.push_scissor(cx, cy, cw, ch)
      content.render(buf, parent_x=cx, parent_y=cy - scroll_y)
      buf.pop_scissor()
    }
    _ => ()
  }
}
