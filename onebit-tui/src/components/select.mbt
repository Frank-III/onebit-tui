///| Select/Dropdown component

pub(all) struct SelectOption {
  value : String
  label : String
  disabled : Bool?
}

/// Dropdown select component
pub fn select(
  options : Array[SelectOption],
  selected : Ref[String],
  placeholder? : String = "Select an option...",
  on_change? : (String) -> Unit = fn(_) {},
  open? : Ref[Bool] = Ref::new(false)
) -> View {
  // Find current label
  let mut current_label = placeholder
  for i = 0; i < options.length(); i = i + 1 {
    if options[i].value == selected.val {
      current_label = options[i].label
      break
    }
  }
  
  View::new()
    .column()
    .children([
      // Dropdown trigger
      View::new()
        .row()
        .justify_content(@types.Justify::SpaceBetween)
        .padding(1.0)
        .border(BorderStyle::Single, @core.Color::Gray)
        .background(if open.val { @core.Color::Gray } else { @core.Color::Black })
        .focusable()
        .on_click(fn(_, _) {
          open.val = not(open.val)
        })
        .on_key(fn(key) {
          match key {
            @ffi.KeyEvent::Char(32) | @ffi.KeyEvent::Enter => { // Space or Enter
              open.val = not(open.val)
              true
            }
            @ffi.KeyEvent::Escape => {
              open.val = false
              true
            }
            @ffi.KeyEvent::ArrowDown => {
              if not(open.val) {
                open.val = true
              } else {
                // Select next option
                select_next_option(options, selected, on_change)
              }
              true
            }
            @ffi.KeyEvent::ArrowUp => {
              if open.val {
                // Select previous option
                select_prev_option(options, selected, on_change)
              }
              true
            }
            _ => false
          }
        })
        .children([
          View::text(current_label, Some(@core.Color::White)),
          View::text(if open.val { "▲" } else { "▼" }, Some(@core.Color::Cyan))
        ]),
      
      // Dropdown menu
      if open.val {
        View::new()
          .column()
          .border(BorderStyle::Single, @core.Color::Gray)
          .background(@core.Color::Black)
          .children(build_option_views(options, selected, open, on_change))
      } else {
        View::new()
      }
    ])
}

fn build_option_views(
  options : Array[SelectOption],
  selected : Ref[String],
  open : Ref[Bool],
  on_change : (String) -> Unit
) -> Array[View] {
  let views : Array[View] = []
  
  for i = 0; i < options.length(); i = i + 1 {
    let option = options[i]
    let is_selected = selected.val == option.value
    let is_disabled = match option.disabled {
      Some(d) => d
      None => false
    }
    
    if not(is_disabled) {
      let view = View::new()
        .row()
        .padding_symmetric(0.5, 1.0)
        .background(if is_selected { @core.Color::Blue } else { @core.Color::Black })
        .focusable()
        .on_click(fn(_, _) {
          selected.val = option.value
          on_change(option.value)
          open.val = false
        })
        .on_key(fn(key) {
          match key {
            @ffi.KeyEvent::Enter => {
              selected.val = option.value
              on_change(option.value)
              open.val = false
              true
            }
            _ => false
          }
        })
        .children([
          View::text(
            if is_selected { "▸ " + option.label } else { "  " + option.label },
            Some(if is_selected { @core.Color::BrightWhite } else { @core.Color::White })
          )
        ])
      views.push(view)
    } else {
      // Disabled option
      let view = View::new()
        .row()
        .padding_symmetric(0.5, 1.0)
        .children([
          View::text("  " + option.label, Some(@core.Color::Gray))
        ])
      views.push(view)
    }
  }
  
  views
}

fn select_next_option(
  options : Array[SelectOption],
  selected : Ref[String],
  on_change : (String) -> Unit
) -> Unit {
  let mut current_index = -1
  for i = 0; i < options.length(); i = i + 1 {
    if options[i].value == selected.val {
      current_index = i
      break
    }
  }
  
  // Find next non-disabled option
  for i = current_index + 1; i < options.length(); i = i + 1 {
    let is_disabled = match options[i].disabled {
      Some(d) => d
      None => false
    }
    if not(is_disabled) {
      selected.val = options[i].value
      on_change(selected.val)
      return
    }
  }
}

fn select_prev_option(
  options : Array[SelectOption],
  selected : Ref[String],
  on_change : (String) -> Unit
) -> Unit {
  let mut current_index = -1
  for i = 0; i < options.length(); i = i + 1 {
    if options[i].value == selected.val {
      current_index = i
      break
    }
  }
  
  // Find previous non-disabled option
  for i = current_index - 1; i >= 0; i = i - 1 {
    let is_disabled = match options[i].disabled {
      Some(d) => d
      None => false
    }
    if not(is_disabled) {
      selected.val = options[i].value
      on_change(selected.val)
      return
    }
  }
}

/// Multi-select dropdown
pub fn multi_select(
  options : Array[SelectOption],
  selected : Ref[Array[String]],
  placeholder? : String = "Select options...",
  on_change? : (Array[String]) -> Unit = fn(_) {},
  open? : Ref[Bool] = Ref::new(false)
) -> View {
  // Build label showing selected items
  let label = if selected.val.length() == 0 {
    placeholder
  } else if selected.val.length() == 1 {
    find_label_for_value(options, selected.val[0])
  } else {
    selected.val.length().to_string() + " selected"
  }
  
  View::new()
    .column()
    .children([
      // Dropdown trigger
      View::new()
        .row()
        .justify_content(@types.Justify::SpaceBetween)
        .padding(1.0)
        .border(BorderStyle::Single, @core.Color::Gray)
        .background(if open.val { @core.Color::Gray } else { @core.Color::Black })
        .focusable()
        .on_click(fn(_, _) {
          open.val = not(open.val)
        })
        .on_key(fn(key) {
          match key {
            @ffi.KeyEvent::Char(32) | @ffi.KeyEvent::Enter => {
              open.val = not(open.val)
              true
            }
            @ffi.KeyEvent::Escape => {
              open.val = false
              true
            }
            _ => false
          }
        })
        .children([
          View::text(label, Some(@core.Color::White)),
          View::text(if open.val { "▲" } else { "▼" }, Some(@core.Color::Cyan))
        ]),
      
      // Dropdown menu with checkboxes
      if open.val {
        View::new()
          .column()
          .padding(1.0)
          .border(BorderStyle::Single, @core.Color::Gray)
          .background(@core.Color::Black)
          .children(build_multi_option_views(options, selected, on_change))
      } else {
        View::new()
      }
    ])
}

fn build_multi_option_views(
  options : Array[SelectOption],
  selected : Ref[Array[String]],
  on_change : (Array[String]) -> Unit
) -> Array[View] {
  let views : Array[View] = []
  
  for i = 0; i < options.length(); i = i + 1 {
    let option = options[i]
    let is_disabled = match option.disabled {
      Some(d) => d
      None => false
    }
    
    if not(is_disabled) {
      let is_checked = Ref::new(array_contains(selected.val, option.value))
      
      let view = checkbox(
        option.label,
        is_checked,
        on_change=fn(checked) {
          if checked {
            // Add to selected
            if not(array_contains(selected.val, option.value)) {
              selected.val.push(option.value)
            }
          } else {
            // Remove from selected
            let new_selected : Array[String] = []
            for j = 0; j < selected.val.length(); j = j + 1 {
              if selected.val[j] != option.value {
                new_selected.push(selected.val[j])
              }
            }
            selected.val = new_selected
          }
          on_change(selected.val)
        }
      )
      views.push(view)
    } else {
      // Disabled option
      let view = View::new()
        .row()
        .gap(1.0)
        .children([
          View::text("[ ]", Some(@core.Color::Gray)),
          View::text(option.label, Some(@core.Color::Gray))
        ])
      views.push(view)
    }
  }
  
  views
}

fn find_label_for_value(options : Array[SelectOption], value : String) -> String {
  for i = 0; i < options.length(); i = i + 1 {
    if options[i].value == value {
      return options[i].label
    }
  }
  value
}

// Use the array_contains from checkbox module