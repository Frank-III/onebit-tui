///|
/// List Component with Scrolling Support
/// Provides scrollable lists with keyboard navigation
pub(all) struct ListItem {
  id : String
  text : String
  icon : String?
  data : String?
}

///|
pub(all) struct List {
  base : @core.BaseRenderable
  items : Array[ListItem]
  mut selected_index : Int
  mut scroll_offset : Int
  mut focused : Bool

  // Styling
  item_height : Int
  padding : Int
  mut border_style : @core.BorderStyle
  mut border_color : @core.RGBA
  mut text_color : @core.RGBA
  mut selected_bg_color : @core.RGBA
  selected_text_color : @core.RGBA

  // Callbacks
  mut on_select : ((ListItem) -> Unit)?
  mut on_change : ((Int) -> Unit)?
}

/// Get the base renderable
pub fn as_renderable(self : List) -> @core.BaseRenderable {
  self.base
}

///|
pub fn List::new(id : String, items : Array[ListItem]) -> List {
  let base = @core.BaseRenderable::new(id)
  base.width = 20
  base.height = 10
  base.background_color = @core.RGBA::black()
  base.foreground_color = @core.RGBA::white()
  
  let list = {
    base,
    items,
    selected_index: 0,
    scroll_offset: 0,
    focused: false,
    item_height: 1,
    padding: 1,
    border_style: @core.BorderStyle::Single,
    border_color: @core.RGBA::white(),
    text_color: @core.RGBA::white(),
    selected_bg_color: @core.RGBA::blue(),
    selected_text_color: @core.RGBA::white(),
    on_select: None,
    on_change: None,
  }
  
  // Set the render function
  base.set_render_fn(fn(_base, buffer) {
    list.render(buffer)
  })
  
  list
}

///|
pub fn List::set_bounds(
  self : List,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
) -> Unit {
  self.base.x = x
  self.base.y = y
  self.base.width = width
  self.base.height = height
}

///|
pub fn List::select_next(self : List) -> Unit {
  if self.selected_index < self.items.length() - 1 {
    self.selected_index = self.selected_index + 1
    self.ensure_visible()
    self.trigger_change()
  }
}

///|
pub fn List::select_previous(self : List) -> Unit {
  if self.selected_index > 0 {
    self.selected_index = self.selected_index - 1
    self.ensure_visible()
    self.trigger_change()
  }
}

///|
pub fn List::select_first(self : List) -> Unit {
  self.selected_index = 0
  self.scroll_offset = 0
  self.trigger_change()
}

///|
pub fn List::select_last(self : List) -> Unit {
  self.selected_index = self.items.length() - 1
  self.ensure_visible()
  self.trigger_change()
}

///|
pub fn List::page_up(self : List) -> Unit {
  let visible_items = self.get_visible_count()
  self.selected_index = if self.selected_index - visible_items < 0 {
    0
  } else {
    self.selected_index - visible_items
  }
  self.ensure_visible()
  self.trigger_change()
}

///|
pub fn List::page_down(self : List) -> Unit {
  let visible_items = self.get_visible_count()
  let max_index = self.items.length() - 1
  self.selected_index = if self.selected_index + visible_items > max_index {
    max_index
  } else {
    self.selected_index + visible_items
  }
  self.ensure_visible()
  self.trigger_change()
}

///|
fn List::ensure_visible(self : List) -> Unit {
  let visible_items = self.get_visible_count()

  // Scroll up if item is above visible area
  if self.selected_index < self.scroll_offset {
    self.scroll_offset = self.selected_index
  }

  // Scroll down if item is below visible area
  if self.selected_index >= self.scroll_offset + visible_items {
    self.scroll_offset = self.selected_index - visible_items + 1
  }
}

///|
fn List::get_visible_count(self : List) -> Int {
  let content_height = self.base.height - 2 * self.padding
  let border_height = if self.border_style == @core.BorderStyle::None {
    0
  } else {
    2
  }
  (content_height - border_height) / self.item_height
}

///|
fn List::trigger_change(self : List) -> Unit {
  match self.on_change {
    Some(cb) => cb(self.selected_index)
    None => ()
  }
}

///|
pub fn List::confirm_selection(self : List) -> Unit {
  if self.selected_index >= 0 && self.selected_index < self.items.length() {
    let item = self.items[self.selected_index]
    match self.on_select {
      Some(cb) => cb(item)
      None => ()
    }
  }
}

///|
pub fn List::render(self : List, buffer : @core.TerminalBuffer) -> Unit {
  if not(self.base.visible) {
    return
  }

  // Clear background
  buffer.fill_rect(
    self.base.x,
    self.base.y,
    self.base.width,
    self.base.height,
    ' ',
    self.text_color,
    self.base.background_color,
    @core.TextStyle::None,
  )

  // Draw border
  if self.border_style != @core.BorderStyle::None {
    draw_border(
      buffer,
      self.base.x,
      self.base.y,
      self.base.width,
      self.base.height,
      self.border_style,
      self.border_color,
      self.base.background_color,
    )
  }

  // Calculate content area
  let border_offset = if self.border_style == @core.BorderStyle::None {
    0
  } else {
    1
  }
  let content_x = self.base.x + border_offset + self.padding
  let content_y = self.base.y + border_offset + self.padding
  let content_width = self.base.width - 2 * (border_offset + self.padding)
  let visible_items = self.get_visible_count()

  // Render visible items
  for i = 0; i < visible_items; i = i + 1 {
    let item_index = self.scroll_offset + i
    if item_index >= self.items.length() {
      break
    }
    let item = self.items[item_index]
    let y = content_y + i * self.item_height
    let is_selected = item_index == self.selected_index

    // Background for selected item
    if is_selected {
      buffer.fill_rect(
        content_x,
        y,
        content_width,
        self.item_height,
        ' ',
        self.selected_text_color,
        self.selected_bg_color,
        @core.TextStyle::None,
      )
    }

    // Icon and text
    let mut text_x = content_x
    match item.icon {
      Some(icon) => {
        buffer.write_string(
          text_x,
          y,
          icon,
          if is_selected {
            self.selected_text_color
          } else {
            self.text_color
          },
          if is_selected {
            self.selected_bg_color
          } else {
            self.base.background_color
          },
          @core.TextStyle::None,
        )
        text_x = text_x + icon.length() + 1
      }
      None => ()
    }

    // Truncate text if too long
    let max_text_width = content_width - (text_x - content_x)
    let display_text = if item.text.length() > max_text_width {
      @core.string_substring(item.text, 0, max_text_width - 3) + "..."
    } else {
      item.text
    }
    buffer.write_string(
      text_x,
      y,
      display_text,
      if is_selected {
        self.selected_text_color
      } else {
        self.text_color
      },
      if is_selected {
        self.selected_bg_color
      } else {
        self.background_color
      },
      @core.TextStyle::None,
    )
  }

  // Draw scrollbar if needed
  if self.items.length() > visible_items {
    draw_scrollbar(
      buffer,
      self.base.x + self.base.width - border_offset - 1,
      self.base.y + border_offset,
      self.base.height - 2 * border_offset,
      self.scroll_offset,
      visible_items,
      self.items.length(),
      self.border_color,
      self.base.background_color,
    )
  }
}

///| Helper to draw border
fn draw_border(
  buffer : @core.TerminalBuffer,
  x : Int,
  y : Int,
  width : Int,
  height : Int,
  style : @core.BorderStyle,
  fg : @core.RGBA,
  bg : @core.RGBA,
) -> Unit {
  let chars = match style {
    @core.BorderStyle::Single => ('─', '│', '┌', '┐', '└', '┘')
    @core.BorderStyle::Double => ('═', '║', '╔', '╗', '╚', '╝')
    @core.BorderStyle::Thick => ('━', '┃', '┏', '┓', '┗', '┛')
    @core.BorderStyle::Rounded => ('─', '│', '╭', '╮', '╰', '╯')
    _ => (' ', ' ', ' ', ' ', ' ', ' ')
  }
  let (h_line, v_line, tl, tr, bl, br) = chars

  // Corners
  buffer.write_char(x, y, tl, fg, bg, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y, tr, fg, bg, @core.TextStyle::None)
  buffer.write_char(x, y + height - 1, bl, fg, bg, @core.TextStyle::None)
  buffer.write_char(
    x + width - 1,
    y + height - 1,
    br,
    fg,
    bg,
    @core.TextStyle::None,
  )

  // Horizontal lines
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_char(x + i, y, h_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(
      x + i,
      y + height - 1,
      h_line,
      fg,
      bg,
      @core.TextStyle::None,
    )
  }

  // Vertical lines
  for i = 1; i < height - 1; i = i + 1 {
    buffer.write_char(x, y + i, v_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(
      x + width - 1,
      y + i,
      v_line,
      fg,
      bg,
      @core.TextStyle::None,
    )
  }
}

///| Helper to draw scrollbar
fn draw_scrollbar(
  buffer : @core.TerminalBuffer,
  x : Int,
  y : Int,
  height : Int,
  offset : Int,
  visible_count : Int,
  total_count : Int,
  fg : @core.RGBA,
  bg : @core.RGBA,
) -> Unit {
  // Calculate thumb size and position
  let thumb_size = (visible_count.to_double() /
  total_count.to_double() *
  height.to_double()).to_int()
  let thumb_size_final = if thumb_size < 1 { 1 } else { thumb_size }
  let max_offset = total_count - visible_count
  let thumb_position = if max_offset > 0 {
    (offset.to_double() /
    max_offset.to_double() *
    (height - thumb_size_final).to_double()).to_int()
  } else {
    0
  }

  // Draw track
  for i = 0; i < height; i = i + 1 {
    buffer.write_char(x, y + i, '│', fg, bg, @core.TextStyle::Dim)
  }

  // Draw thumb
  for i = 0; i < thumb_size_final; i = i + 1 {
    buffer.write_char(
      x,
      y + thumb_position + i,
      '█',
      fg,
      bg,
      @core.TextStyle::None,
    )
  }
}

///| Builder pattern for List
pub fn List::builder(id : String) -> ListBuilder {
  ListBuilder::new(id)
}

///|
pub struct ListBuilder {
  id : String
  mut items : Array[ListItem]
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  mut border_style : @core.BorderStyle
  mut selected_bg_color : @core.RGBA
  mut on_select : ((ListItem) -> Unit)?
}

///|
pub fn ListBuilder::new(id : String) -> ListBuilder {
  {
    id,
    items: [],
    x: 0,
    y: 0,
    width: 20,
    height: 10,
    border_style: @core.BorderStyle::Single,
    selected_bg_color: @core.RGBA::blue(),
    on_select: None,
  }
}

///|
pub fn ListBuilder::position(
  self : ListBuilder,
  x : Int,
  y : Int,
) -> ListBuilder {
  self.x = x
  self.y = y
  self
}

///|
pub fn ListBuilder::size(
  self : ListBuilder,
  width : Int,
  height : Int,
) -> ListBuilder {
  self.width = width
  self.height = height
  self
}

///|
pub fn ListBuilder::items(
  self : ListBuilder,
  items : Array[ListItem],
) -> ListBuilder {
  self.items = items
  self
}

///|
pub fn ListBuilder::add_item(
  self : ListBuilder,
  text : String,
  icon? : String,
  data? : String,
) -> ListBuilder {
  let item = { id: "item_" + self.items.length().to_string(), text, icon, data }
  self.items.push(item)
  self
}

///|
pub fn ListBuilder::border(
  self : ListBuilder,
  style : @core.BorderStyle,
) -> ListBuilder {
  self.border_style = style
  self
}

///|
pub fn ListBuilder::selection_color(
  self : ListBuilder,
  r : Double,
  g : Double,
  b : Double,
) -> ListBuilder {
  self.selected_bg_color = @core.RGBA::rgb(r, g, b)
  self
}

///|
pub fn ListBuilder::on_select(
  self : ListBuilder,
  handler : (ListItem) -> Unit,
) -> ListBuilder {
  self.on_select = Some(handler)
  self
}

///|
pub fn ListBuilder::build(self : ListBuilder) -> List {
  let list = List::new(self.id, self.items)
  list.set_bounds(self.x, self.y, self.width, self.height)
  list.border_style = self.border_style
  list.selected_bg_color = self.selected_bg_color
  list.on_select = self.on_select
  list
}
