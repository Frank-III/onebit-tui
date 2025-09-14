///|
/// Table Component
/// Provides tabular data display with sorting, filtering, and pagination

pub struct Table[T] {
  base : @core.BaseRenderable
  mut focused : Bool
  
  // Data
  columns : Array[TableColumn[T]]
  mut data : Array[T]
  mut filtered_data : Array[T]
  mut display_data : Array[T]
  
  // State
  mut selected_row : Int
  mut selected_column : Int
  mut sort_column : Option[Int]
  mut sort_ascending : Bool
  mut current_page : Int
  mut rows_per_page : Int
  
  // Filter
  mut filter_text : String
  mut filter_column : Option[Int]
  
  // Styling
  header_bg_color : @core.RGBA
  header_text_color : @core.RGBA
  row_bg_color : @core.RGBA
  row_alt_bg_color : @core.RGBA
  row_text_color : @core.RGBA
  selected_bg_color : @core.RGBA
  selected_text_color : @core.RGBA
  border_style : @core.BorderStyle
  border_color : @core.RGBA
  mut show_row_numbers : Bool
  
  // Callbacks
  mut on_select : Option[(T) -> Unit]
  mut on_sort : Option[(Int, Bool) -> Unit]
}

pub struct TableColumn[T] {
  key : String
  title : String
  width : Int
  getter : (T) -> String
  sortable : Bool
  filterable : Bool
  align : @core.TextAlign
}

/// Get the base renderable
pub fn[T] Table::as_renderable(self : Table[T]) -> @core.BaseRenderable {
  self.base
}

pub fn[T] Table::new(id : String, columns : Array[TableColumn[T]]) -> Table[T] {
  let base = @core.BaseRenderable::new(id)
  base.width = 60
  base.height = 20
  base.background_color = @core.RGBA::black()
  base.foreground_color = @core.RGBA::white()
  
  let table = {
    base,
    focused: false,
    columns,
    data: [],
    filtered_data: [],
    display_data: [],
    selected_row: 0,
    selected_column: 0,
    sort_column: None,
    sort_ascending: true,
    current_page: 0,
    rows_per_page: 10,
    filter_text: "",
    filter_column: None,
    header_bg_color: @core.RGBA::rgb(0.2, 0.2, 0.3),
    header_text_color: @core.RGBA::white(),
    row_bg_color: @core.RGBA::black(),
    row_alt_bg_color: @core.RGBA::rgb(0.05, 0.05, 0.05),
    row_text_color: @core.RGBA::white(),
    selected_bg_color: @core.RGBA::rgb(0.2, 0.4, 0.8),
    selected_text_color: @core.RGBA::white(),
    border_style: @core.BorderStyle::Single,
    border_color: @core.RGBA::gray(),
    show_row_numbers: false,
    on_select: None,
    on_sort: None
  }
  
  // Set the render function
  base.set_render_fn(fn(_base, buffer) {
    table.render(buffer)
  })
  
  table
}

pub fn[T] Table::set_data(self : Table[T], data : Array[T]) -> Unit {
  self.data = data
  self.apply_filter()
  self.apply_sort()
  self.update_display_data()
}

pub fn[T] Table::set_bounds(self : Table[T], x : Int, y : Int, width : Int, height : Int) -> Unit {
  self.base.x = x
  self.base.y = y
  self.base.width = width
  self.base.height = height
  // Recalculate rows per page
  let header_height = 3 // header + separator
  let border_height = if self.border_style == @core.BorderStyle::None { 0 } else { 2 }
  self.rows_per_page = (height - header_height - border_height)
}

// Navigation
pub fn[T] Table::select_next_row(self : Table[T]) -> Unit {
  if self.selected_row < self.display_data.length() - 1 {
    self.selected_row = self.selected_row + 1
    // Check if we need to go to next page
    let row_in_page = self.selected_row - (self.current_page * self.rows_per_page)
    if row_in_page >= self.rows_per_page {
      self.next_page()
    }
  }
}

pub fn[T] Table::select_previous_row(self : Table[T]) -> Unit {
  if self.selected_row > 0 {
    self.selected_row = self.selected_row - 1
    // Check if we need to go to previous page
    let row_in_page = self.selected_row - (self.current_page * self.rows_per_page)
    if row_in_page < 0 {
      self.previous_page()
    }
  }
}

pub fn[T] Table::select_next_column(self : Table[T]) -> Unit {
  if self.selected_column < self.columns.length() - 1 {
    self.selected_column = self.selected_column + 1
  }
}

pub fn[T] Table::select_previous_column(self : Table[T]) -> Unit {
  if self.selected_column > 0 {
    self.selected_column = self.selected_column - 1
  }
}

pub fn[T] Table::next_page(self : Table[T]) -> Unit {
  let max_pages = (self.display_data.length() + self.rows_per_page - 1) / self.rows_per_page
  if self.current_page < max_pages - 1 {
    self.current_page = self.current_page + 1
  }
}

pub fn[T] Table::previous_page(self : Table[T]) -> Unit {
  if self.current_page > 0 {
    self.current_page = self.current_page - 1
  }
}

pub fn[T] Table::first_page(self : Table[T]) -> Unit {
  self.current_page = 0
  self.selected_row = 0
}

pub fn[T] Table::last_page(self : Table[T]) -> Unit {
  let max_pages = (self.display_data.length() + self.rows_per_page - 1) / self.rows_per_page
  self.current_page = max_pages - 1
  self.selected_row = self.display_data.length() - 1
}

// Sorting
pub fn[T] Table::sort_by_column(self : Table[T], column_index : Int) -> Unit {
  if column_index < 0 || column_index >= self.columns.length() {
    return
  }
  
  let column = self.columns[column_index]
  if not(column.sortable) {
    return
  }
  
  // Toggle sort direction if same column
  if self.sort_column == Some(column_index) {
    self.sort_ascending = not(self.sort_ascending)
  } else {
    self.sort_column = Some(column_index)
    self.sort_ascending = true
  }
  
  self.apply_sort()
  self.update_display_data()
  
  match self.on_sort {
    Some(cb) => cb(column_index, self.sort_ascending)
    None => ()
  }
}

fn Table::apply_sort[T](self : Table[T]) -> Unit {
  match self.sort_column {
    Some(col_idx) => {
      let column = self.columns[col_idx]
      // Sort filtered data
      self.filtered_data = sort_array(
        self.filtered_data,
        fn(a, b) {
          let a_val = (column.getter)(a)
          let b_val = (column.getter)(b)
          let cmp = compare_strings(a_val, b_val)
          if self.sort_ascending { cmp } else { -cmp }
        }
      )
    }
    None => ()
  }
}

// Filtering
pub fn[T] Table::set_filter(self : Table[T], text : String, column_index? : Int) -> Unit {
  self.filter_text = text
  self.filter_column = column_index
  self.apply_filter()
  self.apply_sort()
  self.update_display_data()
  self.selected_row = 0
  self.current_page = 0
}

pub fn[T] Table::clear_filter(self : Table[T]) -> Unit {
  self.filter_text = ""
  self.filter_column = None
  self.apply_filter()
  self.apply_sort()
  self.update_display_data()
}

fn Table::apply_filter[T](self : Table[T]) -> Unit {
  if self.filter_text.length() == 0 {
    self.filtered_data = self.data
    return
  }
  
  let filter_lower = to_lowercase(self.filter_text)
  self.filtered_data = []
  
  for i = 0; i < self.data.length(); i = i + 1 {
    let item = self.data[i]
    let matches = match self.filter_column {
      Some(col_idx) => {
        let column = self.columns[col_idx]
        if column.filterable {
          let value = to_lowercase((column.getter)(item))
          contains_substring(value, filter_lower)
        } else {
          true
        }
      }
      None => {
        // Search all filterable columns
        let mut any_match = false
        for j = 0; j < self.columns.length(); j = j + 1 {
          let column = self.columns[j]
          if column.filterable {
            let value = to_lowercase((column.getter)(item))
            if contains_substring(value, filter_lower) {
              any_match = true
              break
            }
          }
        }
        any_match
      }
    }
    
    if matches {
      self.filtered_data.push(item)
    }
  }
}

fn Table::update_display_data[T](self : Table[T]) -> Unit {
  self.display_data = self.filtered_data
}

pub fn[T] Table::get_selected_item(self : Table[T]) -> Option[T] {
  if self.selected_row >= 0 && self.selected_row < self.display_data.length() {
    Some(self.display_data[self.selected_row])
  } else {
    None
  }
}

pub fn[T] Table::confirm_selection(self : Table[T]) -> Unit {
  match self.get_selected_item() {
    Some(item) => {
      match self.on_select {
        Some(cb) => cb(item)
        None => ()
      }
    }
    None => ()
  }
}

// Rendering
pub fn[T] Table::render(self : Table[T], buffer : @core.TerminalBuffer) -> Unit {
  if not(self.base.visible) {
    return
  }
  
  let has_border = self.border_style != @core.BorderStyle::None
  let border_offset = if has_border { 1 } else { 0 }
  let content_x = self.base.x + border_offset
  let content_y = self.base.y + border_offset
  let content_width = self.base.width - 2 * border_offset
  let content_height = self.base.height - 2 * border_offset
  
  // Clear background
  buffer.fill_rect(
    self.base.x,
    self.base.y,
    self.base.width,
    self.base.height,
    ' ',
    self.row_text_color,
    self.row_bg_color,
    @core.TextStyle::None
  )
  
  // Draw border
  if has_border {
    draw_table_border(
      buffer,
      self.base.x,
      self.base.y,
      self.base.width,
      self.base.height,
      self.border_style,
      self.border_color,
      self.row_bg_color
    )
  }
  
  // Calculate column positions
  let mut col_positions : Array[Int] = []
  let mut current_x = content_x
  
  if self.show_row_numbers {
    col_positions.push(current_x)
    current_x = current_x + 4 // Width for row numbers
  }
  
  for i = 0; i < self.columns.length(); i = i + 1 {
    col_positions.push(current_x)
    current_x = current_x + self.columns[i].width + 1
  }
  
  // Draw header
  let mut header_y = content_y
  
  // Header background
  buffer.fill_rect(
    content_x,
    header_y,
    content_width,
    1,
    ' ',
    self.header_text_color,
    self.header_bg_color,
    @core.TextStyle::None
  )
  
  // Row numbers header
  if self.show_row_numbers {
    buffer.write_string(
      col_positions[0],
      header_y,
      "#",
      self.header_text_color,
      self.header_bg_color,
      @core.TextStyle::Bold
    )
  }
  
  // Column headers
  let col_start = if self.show_row_numbers { 1 } else { 0 }
  for i = 0; i < self.columns.length(); i = i + 1 {
    let column = self.columns[i]
    let col_x = col_positions[col_start + i]
    let mut header_text = column.title
    
    // Add sort indicator
    if self.sort_column == Some(i) {
      header_text = header_text + (if self.sort_ascending { " ▲" } else { " ▼" })
    }
    
    // Truncate if needed
    if header_text.length() > column.width {
      header_text = @core.string_substring(header_text, 0, column.width - 1) + "…"
    }
    
    buffer.write_string(
      col_x,
      header_y,
      header_text,
      self.header_text_color,
      self.header_bg_color,
      @core.TextStyle::Bold
    )
  }
  
  // Header separator
  header_y = header_y + 1
  for x = content_x; x < content_x + content_width; x = x + 1 {
    buffer.write_char(
      x,
      header_y,
      '─',
      self.border_color,
      self.row_bg_color,
      @core.TextStyle::None
    )
  }
  
  // Helper function
  fn min(a : Int, b : Int) -> Int { if a < b { a } else { b } }
  
  // Data rows
  let data_start_y = header_y + 1
  let start_row = self.current_page * self.rows_per_page
  let end_row = min(start_row + self.rows_per_page, self.display_data.length())
  
  for row_idx = start_row; row_idx < end_row; row_idx = row_idx + 1 {
    let row_y = data_start_y + (row_idx - start_row)
    let item = self.display_data[row_idx]
    let is_selected = row_idx == self.selected_row
    let is_alt_row = (row_idx - start_row) % 2 == 1
    
    // Row background
    let row_bg = if is_selected {
      self.selected_bg_color
    } else if is_alt_row {
      self.row_alt_bg_color
    } else {
      self.row_bg_color
    }
    
    let text_color = if is_selected { self.selected_text_color } else { self.row_text_color }
    
    // Clear row
    buffer.fill_rect(
      content_x,
      row_y,
      content_width,
      1,
      ' ',
      text_color,
      row_bg,
      @core.TextStyle::None
    )
    
    // Row number
    if self.show_row_numbers {
      buffer.write_string(
        col_positions[0],
        row_y,
        (row_idx + 1).to_string(),
        text_color,
        row_bg,
        @core.TextStyle::None
      )
    }
    
    // Cell data
    for col_idx = 0; col_idx < self.columns.length(); col_idx = col_idx + 1 {
      let column = self.columns[col_idx]
      let col_x = col_positions[col_start + col_idx]
      let cell_value = (column.getter)(item)
      
      // Truncate if needed
      let display_value = if cell_value.length() > column.width {
        @core.string_substring(cell_value, 0, column.width - 1) + "…"
      } else {
        cell_value
      }
      
      // Apply alignment
      let aligned_x = match column.align {
        @core.TextAlign::Left => col_x
        @core.TextAlign::Right => col_x + column.width - display_value.length()
        @core.TextAlign::Center => col_x + (column.width - display_value.length()) / 2
      }
      
      buffer.write_string(
        aligned_x,
        row_y,
        display_value,
        text_color,
        row_bg,
        @core.TextStyle::None
      )
    }
  }
  
  // Status bar
  let status_y = self.base.y + self.base.height - border_offset - 1
  let page_info = "Page " + (self.current_page + 1).to_string() + 
                  "/" + ((self.display_data.length() + self.rows_per_page - 1) / self.rows_per_page).to_string()
  let row_info = "Row " + (self.selected_row + 1).to_string() + "/" + self.display_data.length().to_string()
  
  if self.filter_text.length() > 0 {
    let filter_info = "Filter: " + self.filter_text
    buffer.write_string(
      content_x,
      status_y,
      filter_info,
      @core.RGBA::yellow(),
      self.row_bg_color,
      @core.TextStyle::None
    )
  }
  
  buffer.write_string(
    content_x + content_width - page_info.length() - row_info.length() - 2,
    status_y,
    row_info,
    @core.RGBA::gray(),
    self.row_bg_color,
    @core.TextStyle::None
  )
  
  buffer.write_string(
    content_x + content_width - page_info.length(),
    status_y,
    page_info,
    @core.RGBA::gray(),
    self.row_bg_color,
    @core.TextStyle::None
  )
}

// Helper functions
fn draw_table_border(
  buffer : @core.TerminalBuffer,
  x : Int, y : Int,
  width : Int, height : Int,
  style : @core.BorderStyle,
  fg : @core.RGBA, bg : @core.RGBA
) -> Unit {
  // Same as other border drawing functions
  let chars = match style {
    @core.BorderStyle::Single => ('─', '│', '┌', '┐', '└', '┘')
    @core.BorderStyle::Double => ('═', '║', '╔', '╗', '╚', '╝')
    @core.BorderStyle::Thick => ('━', '┃', '┏', '┓', '┗', '┛')
    @core.BorderStyle::Rounded => ('─', '│', '╭', '╮', '╰', '╯')
    _ => return
  }
  
  let (h_line, v_line, tl, tr, bl, br) = chars
  
  // Corners
  buffer.write_char(x, y, tl, fg, bg, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y, tr, fg, bg, @core.TextStyle::None)
  buffer.write_char(x, y + height - 1, bl, fg, bg, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y + height - 1, br, fg, bg, @core.TextStyle::None)
  
  // Lines
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_char(x + i, y, h_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + i, y + height - 1, h_line, fg, bg, @core.TextStyle::None)
  }
  
  for i = 1; i < height - 1; i = i + 1 {
    buffer.write_char(x, y + i, v_line, fg, bg, @core.TextStyle::None)
    buffer.write_char(x + width - 1, y + i, v_line, fg, bg, @core.TextStyle::None)
  }
}

fn[T] sort_array(arr : Array[T], compare : (T, T) -> Int) -> Array[T] {
  // Simple bubble sort for now
  let result = arr
  let n = result.length()
  for i = 0; i < n - 1; i = i + 1 {
    for j = 0; j < n - i - 1; j = j + 1 {
      if compare(result[j], result[j + 1]) > 0 {
        let temp = result[j]
        result[j] = result[j + 1]
        result[j + 1] = temp
      }
    }
  }
  result
}

fn compare_strings(a : String, b : String) -> Int {
  // Simple string comparison
  if a < b { -1 }
  else if a > b { 1 }
  else { 0 }
}

fn to_lowercase(s : String) -> String {
  // Simple lowercase conversion for ASCII
  let mut result = ""
  for i = 0; i < s.length(); i = i + 1 {
    let ch = s[i]
    if ch >= 65 && ch <= 90 {  // 'A' to 'Z'
      result = result + (ch + 32).to_char().unwrap().to_string()
    } else {
      result = result + ch.to_char().unwrap().to_string()
    }
  }
  result
}

fn contains_substring(haystack : String, needle : String) -> Bool {
  if needle.length() == 0 {
    return true
  }
  if haystack.length() < needle.length() {
    return false
  }
  
  for i = 0; i <= haystack.length() - needle.length(); i = i + 1 {
    let mut matches = true
    for j = 0; j < needle.length(); j = j + 1 {
      if haystack[i + j] != needle[j] {
        matches = false
        break
      }
    }
    if matches {
      return true
    }
  }
  false
}


// Builder for Table
pub struct TableBuilder[T] {
  id : String
  columns : Array[TableColumn[T]]
  mut x : Int
  mut y : Int
  mut width : Int
  mut height : Int
  mut rows_per_page : Int
  mut show_row_numbers : Bool
  mut on_select : Option[(T) -> Unit]
}

pub fn[T] Table::builder(id : String) -> TableBuilder[T] {
  {
    id,
    columns: [],
    x: 0,
    y: 0,
    width: 60,
    height: 20,
    rows_per_page: 10,
    show_row_numbers: false,
    on_select: None
  }
}

pub fn[T] TableBuilder::column(
  self : TableBuilder[T],
  key : String,
  title : String,
  width : Int,
  getter : (T) -> String,
  sortable? : Bool = true,
  filterable? : Bool = true,
  align? : @core.TextAlign = @core.TextAlign::Left
) -> TableBuilder[T] {
  self.columns.push({
    key,
    title,
    width,
    getter,
    sortable,
    filterable,
    align
  })
  self
}

pub fn[T] TableBuilder::position(self : TableBuilder[T], x : Int, y : Int) -> TableBuilder[T] {
  self.x = x
  self.y = y
  self
}

pub fn[T] TableBuilder::size(self : TableBuilder[T], width : Int, height : Int) -> TableBuilder[T] {
  self.width = width
  self.height = height
  self
}

pub fn TableBuilder::rows_per_page[T](self : TableBuilder[T], rows : Int) -> TableBuilder[T] {
  self.rows_per_page = rows
  self
}

pub fn TableBuilder::show_row_numbers[T](self : TableBuilder[T]) -> TableBuilder[T] {
  self.show_row_numbers = true
  self
}

pub fn TableBuilder::on_select[T](self : TableBuilder[T], handler : (T) -> Unit) -> TableBuilder[T] {
  self.on_select = Some(handler)
  self
}

pub fn[T] TableBuilder::build(self : TableBuilder[T]) -> Table[T] {
  let table = Table::new(self.id, self.columns)
  table.set_bounds(self.x, self.y, self.width, self.height)
  table.rows_per_page = self.rows_per_page
  table.show_row_numbers = self.show_row_numbers
  table.on_select = self.on_select
  table
}