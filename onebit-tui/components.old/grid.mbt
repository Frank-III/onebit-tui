///| Grid Layout Component
///| Provides CSS Grid-like layout with rows, columns, and cell spanning

pub(all) enum GridAlign {
  Start
  Center
  End
  Stretch
} derive(Eq)

pub(all) enum GridJustify {
  Start
  Center
  End
  SpaceBetween
  SpaceAround
  SpaceEvenly
  Stretch
} derive(Eq)

pub(all) struct GridCell {
  content : @core.BaseRenderable
  row : Int
  column : Int
  row_span : Int
  column_span : Int
  align : GridAlign?
  justify : GridJustify?
}

pub(all) struct Grid {
  mut base : @core.BaseRenderable
  rows : Int
  columns : Int
  gap : Int
  mut row_gap : Int?
  mut column_gap : Int?
  cells : Array[GridCell]
  row_heights : Array[Int?]
  column_widths : Array[Int?]
  align_items : GridAlign
  justify_items : GridJustify
}

pub fn Grid::new(
  id : String,
  rows : Int,
  columns : Int,
  gap~ : Int = 0,
  align_items~ : GridAlign = GridAlign::Stretch,
  justify_items~ : GridJustify = GridJustify::Stretch
) -> Grid {
  {
    base: @core.BaseRenderable::new(id),
    rows,
    columns,
    gap,
    row_gap: None,
    column_gap: None,
    cells: [],
    row_heights: Array::make(rows, None),
    column_widths: Array::make(columns, None),
    align_items,
    justify_items,
  }
}

pub fn GridCell::new(
  content : @core.BaseRenderable,
  row : Int,
  column : Int,
  row_span~ : Int = 1,
  column_span~ : Int = 1,
  align~ : GridAlign? = None,
  justify~ : GridJustify? = None
) -> GridCell {
  {
    content,
    row,
    column,
    row_span,
    column_span,
    align,
    justify,
  }
}

pub fn Grid::add_cell(self : Grid, cell : GridCell) -> Grid {
  self.cells.push(cell)
  self
}

pub fn Grid::add(
  self : Grid,
  content : @core.BaseRenderable,
  row : Int,
  column : Int,
  row_span~ : Int = 1,
  column_span~ : Int = 1
) -> Grid {
  self.add_cell(GridCell::new(
    content,
    row,
    column,
    row_span~,
    column_span~
  ))
}

pub fn Grid::set_row_height(self : Grid, row : Int, height : Int) -> Grid {
  if row >= 0 && row < self.rows {
    self.row_heights[row] = Some(height)
  }
  self
}

pub fn Grid::set_column_width(self : Grid, column : Int, width : Int) -> Grid {
  if column >= 0 && column < self.columns {
    self.column_widths[column] = Some(width)
  }
  self
}

pub fn Grid::set_row_gap(self : Grid, gap : Int) -> Grid {
  self.row_gap = Some(gap)
  self
}

pub fn Grid::set_column_gap(self : Grid, gap : Int) -> Grid {
  self.column_gap = Some(gap)
  self
}

/// Calculate grid layout
fn calculate_grid_layout(self : Grid) -> (Array[Int], Array[Int]) {
  let row_gap = match self.row_gap {
    Some(gap) => gap
    None => self.gap
  }
  let column_gap = match self.column_gap {
    Some(gap) => gap
    None => self.gap
  }
  
  // Calculate total gaps
  let total_row_gaps = if self.rows > 1 { row_gap * (self.rows - 1) } else { 0 }
  let total_column_gaps = if self.columns > 1 { column_gap * (self.columns - 1) } else { 0 }
  
  // Available space for cells
  let available_height = self.base.height - total_row_gaps
  let available_width = self.base.width - total_column_gaps
  
  // Calculate row heights
  let row_heights = Array::make(self.rows, 0)
  let mut fixed_height = 0
  let mut flex_rows = 0
  
  for i = 0; i < self.rows; i = i + 1 {
    match self.row_heights[i] {
      Some(height) => {
        row_heights[i] = height
        fixed_height = fixed_height + height
      }
      None => {
        flex_rows = flex_rows + 1
      }
    }
  }
  
  let flex_row_height = if flex_rows > 0 {
    let remaining = available_height - fixed_height
    if remaining > 0 { remaining / flex_rows } else { 0 }
  } else {
    0
  }
  
  for i = 0; i < self.rows; i = i + 1 {
    if self.row_heights[i] is None {
      row_heights[i] = flex_row_height
    }
  }
  
  // Calculate column widths
  let column_widths = Array::make(self.columns, 0)
  let mut fixed_width = 0
  let mut flex_columns = 0
  
  for i = 0; i < self.columns; i = i + 1 {
    match self.column_widths[i] {
      Some(width) => {
        column_widths[i] = width
        fixed_width = fixed_width + width
      }
      None => {
        flex_columns = flex_columns + 1
      }
    }
  }
  
  let flex_column_width = if flex_columns > 0 {
    let remaining = available_width - fixed_width
    if remaining > 0 { remaining / flex_columns } else { 0 }
  } else {
    0
  }
  
  for i = 0; i < self.columns; i = i + 1 {
    if self.column_widths[i] is None {
      column_widths[i] = flex_column_width
    }
  }
  
  (row_heights, column_widths)
}

/// Get the base renderable with render function
pub fn Grid::as_renderable(self : Grid) -> @core.BaseRenderable {
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      self.render_grid(buffer)
    })
  }
  self.base
}

/// Render the grid
fn render_grid(self : Grid, buffer : @core.TerminalBuffer) -> Unit {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  
  // Fill background if needed
  if self.base.background_color != @core.RGBA::black() {
    buffer.fill_rect(
      x,
      y,
      self.base.width,
      self.base.height,
      ' ',
      self.base.foreground_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }
  
  // Calculate layout
  let (row_heights, column_widths) = self.calculate_grid_layout()
  
  let row_gap = match self.row_gap {
    Some(gap) => gap
    None => self.gap
  }
  let column_gap = match self.column_gap {
    Some(gap) => gap
    None => self.gap
  }
  
  // Render each cell
  for cell in self.cells {
    if cell.row >= 0 && cell.row < self.rows && 
       cell.column >= 0 && cell.column < self.columns {
      
      // Calculate cell position
      let mut cell_x = x
      let mut cell_y = y
      
      // Add up previous column widths and gaps
      for c = 0; c < cell.column; c = c + 1 {
        cell_x = cell_x + column_widths[c] + column_gap
      }
      
      // Add up previous row heights and gaps
      for r = 0; r < cell.row; r = r + 1 {
        cell_y = cell_y + row_heights[r] + row_gap
      }
      
      // Calculate cell size (accounting for spans)
      let mut cell_width = 0
      let mut cell_height = 0
      
      let end_column = if cell.column + cell.column_span > self.columns {
        self.columns
      } else {
        cell.column + cell.column_span
      }
      
      for c = cell.column; c < end_column; c = c + 1 {
        cell_width = cell_width + column_widths[c]
        if c < end_column - 1 {
          cell_width = cell_width + column_gap
        }
      }
      
      let end_row = if cell.row + cell.row_span > self.rows {
        self.rows
      } else {
        cell.row + cell.row_span
      }
      
      for r = cell.row; r < end_row; r = r + 1 {
        cell_height = cell_height + row_heights[r]
        if r < end_row - 1 {
          cell_height = cell_height + row_gap
        }
      }
      
      // Apply alignment
      let align = match cell.align {
        Some(a) => a
        None => self.align_items
      }
      
      let justify = match cell.justify {
        Some(j) => j
        None => self.justify_items
      }
      
      // Calculate aligned position within cell
      let content_width = cell.content.width
      let content_height = cell.content.height
      
      let aligned_x = match justify {
        GridJustify::Start => cell_x
        GridJustify::Center => cell_x + (cell_width - content_width) / 2
        GridJustify::End => cell_x + cell_width - content_width
        _ => cell_x  // Stretch and space options use full width
      }
      
      let aligned_y = match align {
        GridAlign::Start => cell_y
        GridAlign::Center => cell_y + (cell_height - content_height) / 2
        GridAlign::End => cell_y + cell_height - content_height
        GridAlign::Stretch => cell_y  // Stretch uses full height
      }
      
      // Update content position and size
      cell.content.x = aligned_x
      cell.content.y = aligned_y
      
      // For stretch alignment, update size
      if align == GridAlign::Stretch {
        cell.content.height = cell_height
      }
      if justify == GridJustify::Stretch {
        cell.content.width = cell_width
      }
      
      // Render the content
      cell.content.render(buffer)
    }
  }
}

/// Helper to set dimensions
pub fn Grid::with_dimensions(self : Grid, x : Int, y : Int, width : Int, height : Int) -> Grid {
  { ..self, base: { ..self.base, x, y, width, height } }
}

/// Helper to set background color
pub fn Grid::with_background_color(self : Grid, color : @core.RGBA) -> Grid {
  { ..self, base: { ..self.base, background_color: color } }
}

/// Builder pattern for grid
pub fn Grid::with_gap(self : Grid, gap : Int) -> Grid {
  { ..self, gap }
}

pub fn Grid::with_row_gap(self : Grid, gap : Int) -> Grid {
  { ..self, row_gap: Some(gap) }
}

pub fn Grid::with_column_gap(self : Grid, gap : Int) -> Grid {
  { ..self, column_gap: Some(gap) }
}

pub fn Grid::with_align_items(self : Grid, align : GridAlign) -> Grid {
  { ..self, align_items: align }
}

pub fn Grid::with_justify_items(self : Grid, justify : GridJustify) -> Grid {
  { ..self, justify_items: justify }
}