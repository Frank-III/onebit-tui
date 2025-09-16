///| Modal dialog with focus trap support

// Import needed functions from controls
// Note: make_button is defined in controls.mbt

/// Modal configuration
pub(all) struct ModalConfig {
  title : String
  width : @types.Value?
  height : @types.Value?
  show_close : Bool?
  on_close : (() -> Unit)?
}

/// Create a modal overlay with backdrop and centered dialog
pub fn modal(
  config : ModalConfig,
  content : View,
  open : Ref[Bool]
) -> View {
  if not(open.val) {
    // Return empty view when closed
    return View::new().visible(false)
  }

  let width = match config.width {
    Some(w) => w
    None => @types.Value::percent(60.0)
  }
  let height = match config.height {
    Some(h) => h
    None => @types.Value::percent(50.0)
  }
  
  // For centering, we'll use a container with centering properties
  // Dialog box with focus trap
  let dialog = View::new()
    .width(width)
    .height(height)
    .background(@core.Color::Gray)
    .border(BorderStyle::Double, @core.Color::White)
    .focus_trap()  // Enable focus trapping
    .column()
    .children([
      // Title bar
      View::new()
        .row()
        .justify_content(@types.Justify::SpaceBetween)
        .padding(1.0)
        .background(@core.Color::Blue)
        .children([
          View::text(config.title, Some(@core.Color::BrightWhite)),
          match config.show_close {
            Some(true) | None => View::text("[X]", Some(@core.Color::BrightRed))
              .focusable()
              .on_click(fn(_, _) {
                match config.on_close {
                  Some(close_fn) => close_fn()
                  None => open.val = false
                }
              })
              .on_key(fn(key) {
                match key {
                  @ffi.KeyEvent::Enter | @ffi.KeyEvent::Char(32) => { // Enter or Space
                    match config.on_close {
                      Some(close_fn) => close_fn()
                      None => open.val = false
                    }
                    true
                  }
                  _ => false
                }
              })
            Some(false) => View::new()
          }
        ]),
      // Content area
      View::new()
        .flex(1.0)
        .padding(1.0)
        .children([content])
    ])

  // Container that centers the dialog
  View::new()
    .width(@types.Value::percent(100.0))
    .height(@types.Value::percent(100.0))
    .justify_content(@types.Justify::Center)
    .align_items(@types.Align::Center)
    .background(@core.Color::Black)  // Acts as backdrop with semi-transparency effect
    .children([dialog])
}

/// Simple modal with OK/Cancel buttons
pub fn confirm_modal(
  title : String,
  message : String,
  on_confirm : () -> Unit,
  on_cancel : (() -> Unit)?,
  open : Ref[Bool]
) -> View {
  let content = View::new()
    .column()
    .gap(2.0)
    .children([
      View::text(message, Some(@core.Color::White)),
      View::new()
        .row()
        .justify_content(@types.Justify::Center)
        .gap(2.0)
        .children([
          make_button("OK", true, fn() {
            on_confirm()
            open.val = false
          }),
          make_button("Cancel", false, fn() {
            match on_cancel {
              Some(cancel_fn) => cancel_fn()
              None => ()
            }
            open.val = false
          })
        ])
    ])

  modal(
    {
      title: title,
      width: None,
      height: None,
      show_close: Some(false),
      on_close: None
    },
    content,
    open
  )
}

/// Alert modal with single OK button
pub fn alert_modal(
  title : String,
  message : String,
  open : Ref[Bool]
) -> View {
  let content = View::new()
    .column()
    .gap(2.0)
    .children([
      View::text(message, Some(@core.Color::White)),
      View::new()
        .row()
        .justify_content(@types.Justify::Center)
        .children([
          make_button("OK", true, fn() {
            open.val = false
          })
        ])
    ])

  modal(
    {
      title: title,
      width: None,
      height: None,
      show_close: Some(false),
      on_close: None
    },
    content,
    open
  )
}