///| Table component for displaying tabular data

pub(all) struct Column {
  key : String
  title : String
  width : Int?  // Fixed width in characters
  flex : Double?  // Flex grow for auto-sizing
  align : ColumnAlign?
}

pub(all) enum ColumnAlign {
  Left
  Center
  Right
}

pub(all) struct TableRow {
  cells : Array[String]
  selectable : Bool?
}

/// Table component with header and rows
pub fn table(
  columns : Array[Column],
  rows : Array[TableRow],
  selected_row? : Ref[Int] = Ref::new(-1),
  on_select? : (Int) -> Unit = fn(_) {},
  max_height? : Int = 20,
  show_header? : Bool = true,
  border_style? : BorderStyle = BorderStyle::Single
) -> View {
  // Calculate column widths
  let col_widths = calculate_column_widths(columns, rows)
  
  let mut table_views : Array[View] = []
  
  // Add header if enabled
  if show_header {
    table_views.push(create_header_row(columns, col_widths, border_style))
    table_views.push(create_separator_row(col_widths, border_style))
  }
  
  // Add data rows
  let visible_rows = if rows.length() > max_height { max_height } else { rows.length() }
  for i = 0; i < visible_rows; i = i + 1 {
    let row = rows[i]
    let is_selectable = match row.selectable {
      Some(s) => s
      None => true
    }
    
    let row_view = if is_selectable {
      create_data_row(
        row,
        i,
        col_widths,
        columns,
        selected_row.val == i,
        is_selectable,
        border_style
      )
      .focusable()
      .on_click(fn(_, _) {
        selected_row.val = i
        on_select(i)
      })
      .on_key(fn(key) {
        match key {
          @ffi.KeyEvent::Enter | @ffi.KeyEvent::Char(32) => {
            selected_row.val = i
            on_select(i)
            true
          }
          @ffi.KeyEvent::ArrowUp => {
            if i > 0 {
              selected_row.val = find_prev_selectable(rows, i - 1)
              on_select(selected_row.val)
            }
            true
          }
          @ffi.KeyEvent::ArrowDown => {
            if i < rows.length() - 1 {
              selected_row.val = find_next_selectable(rows, i + 1)
              on_select(selected_row.val)
            }
            true
          }
          _ => false
        }
      })
    } else {
      create_data_row(
        row,
        i,
        col_widths,
        columns,
        selected_row.val == i,
        is_selectable,
        border_style
      )
    }
    
    table_views.push(row_view)
  }
  
  // Add bottom border
  table_views.push(create_bottom_border(col_widths, border_style))
  
  View::new()
    .column()
    .children(table_views)
}

fn calculate_column_widths(columns : Array[Column], rows : Array[TableRow]) -> Array[Int] {
  let widths : Array[Int] = []
  let mut total_flex : Double = 0.0
  let mut fixed_width : Int = 0
  
  // First pass: calculate minimum widths and collect flex
  for i = 0; i < columns.length(); i = i + 1 {
    let col = columns[i]
    match col.width {
      Some(w) => {
        widths.push(w)
        fixed_width = fixed_width + w + 3  // Add padding and border
      }
      None => {
        // Calculate minimum width based on content
        let mut min_width = col.title.length()
        for j = 0; j < rows.length(); j = j + 1 {
          if i < rows[j].cells.length() {
            let cell_len = rows[j].cells[i].length()
            if cell_len > min_width {
              min_width = cell_len
            }
          }
        }
        widths.push(min_width + 2)  // Add padding
        
        match col.flex {
          Some(f) => total_flex = total_flex + f
          None => total_flex = total_flex + 1.0
        }
      }
    }
  }
  
  widths
}

fn create_header_row(
  columns : Array[Column],
  col_widths : Array[Int],
  border_style : BorderStyle
) -> View {
  let cells : Array[View] = []
  
  for i = 0; i < columns.length(); i = i + 1 {
    let col = columns[i]
    let width = col_widths[i]
    let align = match col.align {
      Some(a) => a
      None => ColumnAlign::Left
    }
    
    cells.push(
      View::new()
        .padding_symmetric(0.0, 1.0)
        .children([
          View::text(pad_text(col.title, width, align), Some(@core.Color::BrightWhite))
        ])
    )
  }
  
  View::new()
    .row()
    .background(@core.Color::Blue)
    .children(cells)
}

fn create_data_row(
  row : TableRow,
  row_index : Int,
  col_widths : Array[Int],
  columns : Array[Column],
  is_selected : Bool,
  is_selectable : Bool,
  border_style : BorderStyle
) -> View {
  let cells : Array[View] = []
  
  for i = 0; i < columns.length(); i = i + 1 {
    let text = if i < row.cells.length() { row.cells[i] } else { "" }
    let width = col_widths[i]
    let align = match columns[i].align {
      Some(a) => a
      None => ColumnAlign::Left
    }
    
    cells.push(
      View::new()
        .padding_symmetric(0.0, 1.0)
        .children([
          View::text(
            pad_text(text, width, align),
            Some(if is_selected { @core.Color::BrightWhite } else { @core.Color::White })
          )
        ])
    )
  }
  
  View::new()
    .row()
    .background(if is_selected { 
      @core.Color::Blue 
    } else if row_index % 2 == 0 { 
      @core.Color::Black 
    } else { 
      @core.Color::Gray 
    })
    .children(cells)
}

fn create_separator_row(col_widths : Array[Int], border_style : BorderStyle) -> View {
  let mut separator = ""
  for i = 0; i < col_widths.length(); i = i + 1 {
    for j = 0; j < col_widths[i] + 2; j = j + 1 {
      separator = separator + "─"
    }
    if i < col_widths.length() - 1 {
      separator = separator + "┼"
    }
  }
  
  View::new()
    .children([
      View::text(separator, Some(@core.Color::Gray))
    ])
}

fn create_bottom_border(col_widths : Array[Int], border_style : BorderStyle) -> View {
  let mut border = ""
  for i = 0; i < col_widths.length(); i = i + 1 {
    for j = 0; j < col_widths[i] + 2; j = j + 1 {
      border = border + "─"
    }
    if i < col_widths.length() - 1 {
      border = border + "┴"
    }
  }
  
  View::new()
    .children([
      View::text(border, Some(@core.Color::Gray))
    ])
}

fn pad_text(text : String, width : Int, align : ColumnAlign) -> String {
  let text_len = text.length()
  if text_len >= width {
    return text.substring(start=0, end=width)
  }
  
  let padding = width - text_len
  match align {
    ColumnAlign::Left => text + repeat_char(' ', padding)
    ColumnAlign::Right => repeat_char(' ', padding) + text
    ColumnAlign::Center => {
      let left_pad = padding / 2
      let right_pad = padding - left_pad
      repeat_char(' ', left_pad) + text + repeat_char(' ', right_pad)
    }
  }
}

fn repeat_char(ch : Char, count : Int) -> String {
  let mut result = ""
  for i = 0; i < count; i = i + 1 {
    result = result + ch.to_string()
  }
  result
}

fn find_next_selectable(rows : Array[TableRow], start : Int) -> Int {
  for i = start; i < rows.length(); i = i + 1 {
    let is_selectable = match rows[i].selectable {
      Some(s) => s
      None => true
    }
    if is_selectable {
      return i
    }
  }
  start
}

fn find_prev_selectable(rows : Array[TableRow], start : Int) -> Int {
  for i = start; i >= 0; i = i - 1 {
    let is_selectable = match rows[i].selectable {
      Some(s) => s
      None => true
    }
    if is_selectable {
      return i
    }
  }
  start
}

/// Simple table without selection
pub fn simple_table(
  headers : Array[String],
  data : Array[Array[String]],
  border_style? : BorderStyle = BorderStyle::Single
) -> View {
  let columns : Array[Column] = []
  for i = 0; i < headers.length(); i = i + 1 {
    columns.push({
      key: "col" + i.to_string(),
      title: headers[i],
      width: None,
      flex: Some(1.0),
      align: None
    })
  }
  
  let rows : Array[TableRow] = []
  for i = 0; i < data.length(); i = i + 1 {
    rows.push({
      cells: data[i],
      selectable: Some(false)
    })
  }
  
  table(columns, rows, border_style=border_style)
}