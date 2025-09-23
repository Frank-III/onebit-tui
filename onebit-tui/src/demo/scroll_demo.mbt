///|
/// ScrollBox + Box demo – shows a titled box containing a scrollable list
pub fn main_scroll_demo() -> Unit {
  let app = match @core.App::init() {
    None => {
      println("Failed to initialize app")
      return
    }
    Some(a) => a
  }

  // Build items
  let items : Array[&@view.Component] = []
  for i = 0; i < 30; i = i + 1 {
    let label = "Item #" + i.to_string()
    let text = @widget.Text::body(label)
    items.push(text as &@view.Component)
  }
  let scroll_offset = Ref::new(0)
  let visible = 8
  let build_ui = fn() -> @view.View {
    let list = @widget.ScrollBox::new(
        items,
        visible_rows=visible,
        offset=scroll_offset,
      )
      .title("Items")
      .padding(1.0)

    // Titled box that contains a heading and the scroll list
    let boxed = @widget.Box::new([
        @widget.Text::heading(
          "Scroll Demo (Tab to focus list, Arrow keys to scroll)",
        )
        as &@view.Component,
        list as &@view.Component,
      ])
      .title("Demo")
      .padding(1.0)
      .border(@view.BorderStyle::Single)
    boxed.render()
  }
  @runtime.run_event_loop(app, build_ui, on_global_event=fn(_e) { false })
  app.cleanup()
}

///|
