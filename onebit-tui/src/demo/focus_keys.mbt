///|
/// Focus + Per-Widget Key Handling Demo
/// Demonstrates:
/// - Tab to switch focus between widgets (uses event_loop's built-in focus handling)
/// - Widget-level key handlers via View::on_key
/// - Yoga-based layout (Column with spacing)
pub struct Toggle {
  label : String
  state : Ref[Bool]
  id : Int?
}

///|
pub fn Toggle::new(label : String, initial? : Bool = false) -> Toggle {
  { label, state: Ref::new(initial), id: None }
}

///|
pub impl @view.Component for Toggle with render(self) {
  let text = if self.state.val {
    "[x] " + self.label
  } else {
    "[ ] " + self.label
  }
  let mut view = @view.View::text(text, color=@core.Color::BrightWhite)
    .padding(1.0)
    .height(3.0)
    .border(@view.BorderStyle::Single)
    .focused_border_color(@core.Color::Cyan)
    .focusable()
    .on_key(fn(key) {
      match key {
        @ffi.KeyEvent::Enter | @ffi.KeyEvent::Char(32) => { // Enter or Space
          self.state.val = not(self.state.val)
          true
        }
        _ => false
      }
    })
  match self.id {
    Some(i) => view = view.id(i)
    None => ()
  }
  view
}

///|
pub impl @view.Component for Toggle with handle_event(self, event) {
  match event {
    @events.Event::Key(key) =>
      match key {
        @ffi.KeyEvent::Enter | @ffi.KeyEvent::Char(32) => {
          self.state.val = not(self.state.val)
          true
        }
        _ => false
      }
    _ => false
  }
}

///|
pub impl @view.Component for Toggle with is_focusable(self) {
  true
}

///|
pub fn main_focus_keys() -> Unit {
  let app = match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(a) => a
  }

  // Demo state
  let name = Ref::new("")
  let email = Ref::new("")
  let news = Toggle::new("Subscribe to newsletter", initial=false)

  // Build UI with focusable widgets and per-widget key handlers
  let build_ui = fn() -> @view.View {
    let title = @widget.Text::heading("Focus + Key Handling (Tab to switch)")
    let subtitle = @widget.Text::caption(
      "Type in inputs, Space/Enter toggles checkbox",
    )

    // Two text inputs use widget-level key handling (TextInput::render sets on_key)
    let name_input = @widget.TextInput::new(name)
      .placeholder("Name")
      .width(40.0)
    let email_input = @widget.TextInput::new(email)
      .placeholder("Email")
      .width(40.0)

    // Simple action button to clear fields, with key + mouse handlers in widget
    let clear_btn = @widget.Button::secondary("Clear", fn() {
      name.val = ""
      email.val = ""
    })

    // Layout
    @view.View::container([
      title,
      subtitle,
      name_input,
      email_input,
      news,
      clear_btn,
      @widget.Text::caption(
        "Tips: Tab cycles focus. Backspace edits. Space toggles.",
      ),
    ])
    .direction(@view.Direction::Column)
    .spacing(1.0)
    .padding(2.0)
    .align_items(@types.Align::FlexStart)
  }

  // Use the standard event loop which handles Tab focus and dispatches keys to focused view
  @runtime.run_event_loop(app, build_ui, on_global_event=fn(event) {
    match event {
      // Let 'q' quit via the event loop main switch
      _ => false
    }
  })
  app.cleanup()
}
