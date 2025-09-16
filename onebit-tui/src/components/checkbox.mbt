///| Checkbox and Radio button components

/// Single checkbox with label
pub fn checkbox(
  label : String,
  checked : Ref[Bool],
  on_change? : (Bool) -> Unit = fn(_) {}
) -> View {
  let check_mark = if checked.val { "[✓]" } else { "[ ]" }
  
  View::new()
    .row()
    .gap(1.0)
    .focusable()
    .on_click(fn(_, _) {
      checked.val = not(checked.val)
      on_change(checked.val)
    })
    .on_key(fn(key) {
      match key {
        @ffi.KeyEvent::Char(32) | @ffi.KeyEvent::Enter => { // Space or Enter
          checked.val = not(checked.val)
          on_change(checked.val)
          true
        }
        _ => false
      }
    })
    .children([
      View::new().text_bind(fn() { check_mark }, color=@core.Color::Cyan),
      View::text(label, Some(@core.Color::White))
    ])
}

/// Radio button group
pub(all) struct RadioOption {
  value : String
  label : String
}

pub fn radio_group(
  options : Array[RadioOption],
  selected : Ref[String],
  on_change? : (String) -> Unit = fn(_) {}
) -> View {
  let items : Array[View] = []
  
  for i = 0; i < options.length(); i = i + 1 {
    let option = options[i]
    let is_selected = selected.val == option.value
    let radio_mark = if is_selected { "(•)" } else { "( )" }
    
    let item = View::new()
      .row()
      .gap(1.0)
      .focusable()
      .on_click(fn(_, _) {
        selected.val = option.value
        on_change(option.value)
      })
      .on_key(fn(key) {
        match key {
          @ffi.KeyEvent::Char(32) | @ffi.KeyEvent::Enter => { // Space or Enter
            selected.val = option.value
            on_change(option.value)
            true
          }
          @ffi.KeyEvent::ArrowUp => {
            if i > 0 {
              selected.val = options[i - 1].value
              on_change(selected.val)
            }
            true
          }
          @ffi.KeyEvent::ArrowDown => {
            if i < options.length() - 1 {
              selected.val = options[i + 1].value
              on_change(selected.val)
            }
            true
          }
          _ => false
        }
      })
      .children([
        View::new().text_bind(fn() { 
          if selected.val == option.value { "(•)" } else { "( )" }
        }, color=@core.Color::Cyan),
        View::text(option.label, Some(@core.Color::White))
      ])
    
    items.push(item)
  }
  
  View::new()
    .column()
    .gap(1.0)
    .children(items)
}

/// Toggle switch (on/off)
pub fn toggle(
  label : String,
  enabled : Ref[Bool],
  on_change? : (Bool) -> Unit = fn(_) {}
) -> View {
  View::new()
    .row()
    .gap(1.0)
    .focusable()
    .on_click(fn(_, _) {
      enabled.val = not(enabled.val)
      on_change(enabled.val)
    })
    .on_key(fn(key) {
      match key {
        @ffi.KeyEvent::Char(32) | @ffi.KeyEvent::Enter => { // Space or Enter
          enabled.val = not(enabled.val)
          on_change(enabled.val)
          true
        }
        _ => false
      }
    })
    .children([
      View::text(label, Some(@core.Color::White)),
      View::new()
        .text_bind(fn() { 
          if enabled.val { "[ON ]" } else { "[OFF]" }
        }, color=if enabled.val { @core.Color::BrightGreen } else { @core.Color::Gray })
    ])
}

/// Checkbox group (multiple selection)
pub(all) struct CheckboxOption {
  value : String
  label : String
}

pub fn checkbox_group(
  options : Array[CheckboxOption],
  selected : Ref[Array[String]],
  on_change? : (Array[String]) -> Unit = fn(_) {}
) -> View {
  let items : Array[View] = []
  
  for i = 0; i < options.length(); i = i + 1 {
    let option = options[i]
    let is_checked = Ref::new(array_contains(selected.val, option.value))
    
    let item = checkbox(
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
    
    items.push(item)
  }
  
  View::new()
    .column()
    .gap(1.0)
    .children(items)
}

// Helper function to check if array contains a value
pub fn array_contains(arr : Array[String], value : String) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if arr[i] == value {
      return true
    }
  }
  false
}