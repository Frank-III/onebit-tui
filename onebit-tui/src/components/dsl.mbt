///| DSL for building UIs more declaratively
///| Provides helper functions for common patterns

// Shorthand constructors
pub fn vbox(children : Array[View]) -> View {
  let view = View::new().flex_direction(FlexDirection::Column)
  for i = 0; i < children.length(); i = i + 1 {
    view.add_child(children[i])
  }
  view
}

pub fn hbox(children : Array[View]) -> View {
  let view = View::new().flex_direction(FlexDirection::Row)
  for i = 0; i < children.length(); i = i + 1 {
    view.add_child(children[i])
  }
  view
}

pub fn text(content : String, color : @core.Color?) -> View {
  View::text(content, color)
}

pub fn spacer() -> View {
  View::new().flex(1.0)
}

pub fn divider(horizontal : Bool) -> View {
  if horizontal {
    View::new()
      .height(SizeValue::Points(1.0))
      .background(@core.Color::Gray)
  } else {
    View::new()
      .width(SizeValue::Points(1.0))
      .background(@core.Color::Gray)
  }
}

// Common layouts
pub fn center(child : View) -> View {
  View::new()
    .justify_content(Justify::Center)
    .align_items(Align::Center)
    .add_child(child)
}

pub fn card(title : String, content : View) -> View {
  vbox([
    View::new()
      .padding(1.0)
      .background(@core.Color::DarkBlue)
      .add_child(text(title, Some(@core.Color::BrightWhite))),
    View::new()
      .padding(2.0)
      .add_child(content)
  ])
  .border(BorderStyle::Rounded, @core.Color::Blue)
}

pub fn list(items : Array[String]) -> View {
  let children : Array[View] = []
  for i = 0; i < items.length(); i = i + 1 {
    children.push(
      hbox([
        text("• ", Some(@core.Color::Gray)),
        text(items[i], None)
      ])
      .padding(0.5)
    )
  }
  vbox(children)
}

// Layout presets
pub fn sidebar_layout(sidebar : View, content : View) -> View {
  hbox([
    sidebar.width(SizeValue::Points(20.0)),
    View::new().width(SizeValue::Points(1.0)).background(@core.Color::Gray), // divider
    content.flex(1.0)
  ])
}

pub fn header_body_footer(header : View, body : View, footer : View) -> View {
  vbox([
    header.height(SizeValue::Points(3.0)),
    body.flex(1.0),
    footer.height(SizeValue::Points(1.0))
  ])
}

// Styled components
pub fn button(label : String, primary : Bool) -> View {
  let bg_color = if primary { @core.Color::Blue } else { @core.Color::Gray }
  let text_color = if primary { @core.Color::BrightWhite } else { @core.Color::White }
  
  View::new()
    .padding(1.0)
    .background(bg_color)
    .border(BorderStyle::Single, text_color)
    .add_child(text(label, Some(text_color)))
}

pub fn input_field(placeholder : String, value : String) -> View {
  let display_text = if value.length() > 0 { value } else { placeholder }
  let text_color = if value.length() > 0 { @core.Color::White } else { @core.Color::Gray }
  
  View::new()
    .padding(1.0)
    .border(BorderStyle::Single, @core.Color::White)
    .add_child(text(display_text, Some(text_color)))
}

// Grid layout helper
pub fn grid(columns : Int, items : Array[View]) -> View {
  let rows : Array[View] = []
  let mut current_row : Array[View] = []
  
  for i = 0; i < items.length(); i = i + 1 {
    current_row.push(items[i].flex(1.0))
    
    if current_row.length() == columns || i == items.length() - 1 {
      rows.push(hbox(current_row))
      current_row = []
    }
  }
  
  vbox(rows)
}

// Responsive helpers
pub fn responsive(small : View, large : View, breakpoint : Double) -> View {
  // For now, just return one based on a simple check
  // In a real implementation, this would check terminal width
  large  // TODO: implement actual responsive logic
}

// Example of a complex component built with DSL
pub fn dialog(title : String, message : String, actions : Array[(String, () -> Unit)]) -> View {
  let action_buttons : Array[View] = []
  for i = 0; i < actions.length(); i = i + 1 {
    let (label, _callback) = actions[i]
    action_buttons.push(button(label, i == 0))
  }
  
  center(
    vbox([
      View::new()
        .padding(1.0)
        .background(@core.Color::DarkBlue)
        .add_child(text(title, Some(@core.Color::BrightWhite))),
      View::new()
        .padding(2.0)
        .add_child(text(message, None)),
      hbox(action_buttons)
        .justify_content(Justify::SpaceAround)
        .padding(1.0)
    ])
    .width(SizeValue::Points(40.0))
    .border(BorderStyle::Double, @core.Color::Blue)
  )
}