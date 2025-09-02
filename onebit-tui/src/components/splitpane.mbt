///| SplitPane Component
///| Provides resizable split layout with two or more panes

pub(all) enum SplitDirection {
  Vertical   // Left-Right split
  Horizontal // Top-Bottom split
} derive(Eq)

pub(all) enum SplitMode {
  Fixed      // Fixed size panes
  Percentage // Percentage-based sizing
  Resizable  // User-resizable with divider
} derive(Eq)

pub(all) struct SplitPane {
  mut base : @core.BaseRenderable
  direction : SplitDirection
  mode : SplitMode
  mut split_position : Double  // Position as percentage (0.0 to 1.0) or fixed pixels
  mut min_pane_size : Int
  mut first_pane : @core.BaseRenderable?
  mut second_pane : @core.BaseRenderable?
  divider_style : @core.BorderStyle
  divider_color : @core.RGBA
  mut is_resizing : Bool
  mut hover_divider : Bool
  show_resize_handle : Bool
}

pub fn SplitPane::new(
  id : String,
  direction~ : SplitDirection = SplitDirection::Vertical,
  mode~ : SplitMode = SplitMode::Percentage,
  split_position~ : Double = 0.5,
  min_pane_size~ : Int = 3
) -> SplitPane {
  {
    base: @core.BaseRenderable::new(id),
    direction,
    mode,
    split_position,
    min_pane_size,
    first_pane: None,
    second_pane: None,
    divider_style: @core.BorderStyle::Single,
    divider_color: @core.RGBA::gray(),
    is_resizing: false,
    hover_divider: false,
    show_resize_handle: true,
  }
}

/// Set the first pane content
pub fn SplitPane::set_first_pane(self : SplitPane, content : @core.BaseRenderable) -> SplitPane {
  self.first_pane = Some(content)
  self
}

/// Set the second pane content
pub fn SplitPane::set_second_pane(self : SplitPane, content : @core.BaseRenderable) -> SplitPane {
  self.second_pane = Some(content)
  self
}

/// Set both panes at once
pub fn SplitPane::set_panes(self : SplitPane, first : @core.BaseRenderable, second : @core.BaseRenderable) -> SplitPane {
  self.first_pane = Some(first)
  self.second_pane = Some(second)
  self
}

/// Calculate pane dimensions based on split position
fn calculate_pane_dimensions(self : SplitPane) -> (Int, Int, Int, Int, Int, Int, Int, Int) {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height
  
  match self.direction {
    SplitDirection::Vertical => {
      // Left-Right split
      let divider_x = match self.mode {
        SplitMode::Fixed => x + self.split_position.to_int()
        SplitMode::Percentage | SplitMode::Resizable => {
          x + (width.to_double() * self.split_position).to_int()
        }
      }
      
      // Ensure minimum pane sizes
      let adjusted_divider_x = if divider_x - x < self.min_pane_size {
        x + self.min_pane_size
      } else if x + width - divider_x - 1 < self.min_pane_size {
        x + width - self.min_pane_size - 1
      } else {
        divider_x
      }
      
      let first_x = x
      let first_y = y
      let first_width = adjusted_divider_x - x
      let first_height = height
      
      let second_x = adjusted_divider_x + 1
      let second_y = y
      let second_width = x + width - adjusted_divider_x - 1
      let second_height = height
      
      (first_x, first_y, first_width, first_height, second_x, second_y, second_width, second_height)
    }
    SplitDirection::Horizontal => {
      // Top-Bottom split
      let divider_y = match self.mode {
        SplitMode::Fixed => y + self.split_position.to_int()
        SplitMode::Percentage | SplitMode::Resizable => {
          y + (height.to_double() * self.split_position).to_int()
        }
      }
      
      // Ensure minimum pane sizes
      let adjusted_divider_y = if divider_y - y < self.min_pane_size {
        y + self.min_pane_size
      } else if y + height - divider_y - 1 < self.min_pane_size {
        y + height - self.min_pane_size - 1
      } else {
        divider_y
      }
      
      let first_x = x
      let first_y = y
      let first_width = width
      let first_height = adjusted_divider_y - y
      
      let second_x = x
      let second_y = adjusted_divider_y + 1
      let second_width = width
      let second_height = y + height - adjusted_divider_y - 1
      
      (first_x, first_y, first_width, first_height, second_x, second_y, second_width, second_height)
    }
  }
}

/// Handle mouse events for resizing
pub fn SplitPane::handle_mouse_down(self : SplitPane, mouse_x : Int, mouse_y : Int) -> Bool {
  if self.mode != SplitMode::Resizable {
    return false
  }
  
  let (fx, fy, fw, fh, sx, sy, sw, sh) = self.calculate_pane_dimensions()
  
  match self.direction {
    SplitDirection::Vertical => {
      let divider_x = fx + fw
      if mouse_x == divider_x && mouse_y >= fy && mouse_y < fy + fh {
        self.is_resizing = true
        return true
      }
    }
    SplitDirection::Horizontal => {
      let divider_y = fy + fh
      if mouse_y == divider_y && mouse_x >= fx && mouse_x < fx + fw {
        self.is_resizing = true
        return true
      }
    }
  }
  
  false
}

/// Handle mouse drag for resizing
pub fn SplitPane::handle_mouse_drag(self : SplitPane, mouse_x : Int, mouse_y : Int) -> Unit {
  if not(self.is_resizing) || self.mode != SplitMode::Resizable {
    return
  }
  
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height
  
  match self.direction {
    SplitDirection::Vertical => {
      let new_position = (mouse_x - x).to_double() / width.to_double()
      self.split_position = if new_position < 0.1 {
        0.1
      } else if new_position > 0.9 {
        0.9
      } else {
        new_position
      }
    }
    SplitDirection::Horizontal => {
      let new_position = (mouse_y - y).to_double() / height.to_double()
      self.split_position = if new_position < 0.1 {
        0.1
      } else if new_position > 0.9 {
        0.9
      } else {
        new_position
      }
    }
  }
}

/// Handle mouse up to stop resizing
pub fn SplitPane::handle_mouse_up(self : SplitPane) -> Unit {
  self.is_resizing = false
}

/// Handle mouse hover for visual feedback
pub fn SplitPane::handle_mouse_move(self : SplitPane, mouse_x : Int, mouse_y : Int) -> Unit {
  if self.mode != SplitMode::Resizable {
    self.hover_divider = false
    return
  }
  
  let (fx, fy, fw, fh, sx, sy, sw, sh) = self.calculate_pane_dimensions()
  
  match self.direction {
    SplitDirection::Vertical => {
      let divider_x = fx + fw
      self.hover_divider = mouse_x == divider_x && mouse_y >= fy && mouse_y < fy + fh
    }
    SplitDirection::Horizontal => {
      let divider_y = fy + fh
      self.hover_divider = mouse_y == divider_y && mouse_x >= fx && mouse_x < fx + fw
    }
  }
}

/// Get the base renderable with render function
pub fn SplitPane::as_renderable(self : SplitPane) -> @core.BaseRenderable {
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      self.render_splitpane(buffer)
    })
  }
  self.base
}

/// Render the split pane
fn render_splitpane(self : SplitPane, buffer : @core.TerminalBuffer) -> Unit {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  
  // Fill background
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
  
  // Calculate pane dimensions
  let (first_x, first_y, first_width, first_height, second_x, second_y, second_width, second_height) = 
    self.calculate_pane_dimensions()
  
  // Render first pane
  match self.first_pane {
    Some(pane) => {
      pane.x = first_x
      pane.y = first_y
      pane.width = first_width
      pane.height = first_height
      pane.render(buffer)
    }
    None => ()
  }
  
  // Render divider
  self.render_divider(buffer, first_x, first_y, first_width, first_height)
  
  // Render second pane
  match self.second_pane {
    Some(pane) => {
      pane.x = second_x
      pane.y = second_y
      pane.width = second_width
      pane.height = second_height
      pane.render(buffer)
    }
    None => ()
  }
}

/// Render the divider between panes
fn render_divider(self : SplitPane, buffer : @core.TerminalBuffer, fx : Int, fy : Int, fw : Int, fh : Int) -> Unit {
  let divider_color = if self.hover_divider || self.is_resizing {
    @core.RGBA::white()
  } else {
    self.divider_color
  }
  
  let divider_char = match self.divider_style {
    @core.BorderStyle::None => ' '
    @core.BorderStyle::Single => if self.direction == SplitDirection::Vertical { '│' } else { '─' }
    @core.BorderStyle::Double => if self.direction == SplitDirection::Vertical { '║' } else { '═' }
    @core.BorderStyle::Thick => if self.direction == SplitDirection::Vertical { '┃' } else { '━' }
    @core.BorderStyle::Rounded => if self.direction == SplitDirection::Vertical { '│' } else { '─' }
    @core.BorderStyle::Dashed => if self.direction == SplitDirection::Vertical { '┆' } else { '┄' }
    @core.BorderStyle::Dotted => if self.direction == SplitDirection::Vertical { '┊' } else { '┈' }
  }
  
  match self.direction {
    SplitDirection::Vertical => {
      let divider_x = fx + fw
      for i = 0; i < fh; i = i + 1 {
        buffer.write_char(
          divider_x,
          fy + i,
          divider_char,
          divider_color,
          self.base.background_color,
          @core.TextStyle::None,
        )
      }
      
      // Render resize handle if enabled
      if self.show_resize_handle && self.mode == SplitMode::Resizable {
        let handle_y = fy + fh / 2
        buffer.write_char(
          divider_x,
          handle_y,
          if self.hover_divider || self.is_resizing { '◆' } else { '◇' },
          divider_color,
          self.base.background_color,
          @core.TextStyle::None,
        )
      }
    }
    SplitDirection::Horizontal => {
      let divider_y = fy + fh
      for i = 0; i < fw; i = i + 1 {
        buffer.write_char(
          fx + i,
          divider_y,
          divider_char,
          divider_color,
          self.base.background_color,
          @core.TextStyle::None,
        )
      }
      
      // Render resize handle if enabled
      if self.show_resize_handle && self.mode == SplitMode::Resizable {
        let handle_x = fx + fw / 2
        buffer.write_char(
          handle_x,
          divider_y,
          if self.hover_divider || self.is_resizing { '◆' } else { '◇' },
          divider_color,
          self.base.background_color,
          @core.TextStyle::None,
        )
      }
    }
  }
}

/// Helper to set dimensions
pub fn SplitPane::with_dimensions(self : SplitPane, x : Int, y : Int, width : Int, height : Int) -> SplitPane {
  { ..self, base: { ..self.base, x, y, width, height } }
}

/// Set divider style
pub fn SplitPane::with_divider_style(self : SplitPane, style : @core.BorderStyle) -> SplitPane {
  { ..self, divider_style: style }
}

/// Set divider color
pub fn SplitPane::with_divider_color(self : SplitPane, color : @core.RGBA) -> SplitPane {
  { ..self, divider_color: color }
}

/// Set split position
pub fn SplitPane::set_split_position(self : SplitPane, position : Double) -> Unit {
  self.split_position = if position < 0.0 {
    0.0
  } else if position > 1.0 {
    1.0
  } else {
    position
  }
}

/// Toggle resize handle visibility
pub fn SplitPane::with_resize_handle(self : SplitPane, show : Bool) -> SplitPane {
  { ..self, show_resize_handle: show }
}