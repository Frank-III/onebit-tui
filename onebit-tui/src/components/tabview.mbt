///| TabView Component
///| Provides tabbed interface with multiple switchable views

pub(all) enum TabPosition {
  Top
  Bottom
  Left
  Right
} derive(Eq)

pub(all) enum TabStyle {
  Underline
  Box
  Rounded
  Simple
} derive(Eq)

pub(all) struct Tab {
  id : String
  label : String
  content : @core.BaseRenderable
  closable : Bool
  icon : String?
  badge : String?
  mut visible : Bool
}

pub(all) struct TabView {
  mut base : @core.BaseRenderable
  mut tabs : Array[Tab]
  mut active_tab_index : Int
  tab_position : TabPosition
  tab_style : TabStyle
  tab_width : Int?  // Fixed width for tabs, None for auto
  show_overflow_arrows : Bool
  mut scroll_offset : Int
  active_tab_color : @core.RGBA
  inactive_tab_color : @core.RGBA
  tab_background : @core.RGBA
  border_style : @core.BorderStyle
  border_color : @core.RGBA
  mut focused : Bool
}

pub fn TabView::new(
  id : String,
  tab_position~ : TabPosition = TabPosition::Top,
  tab_style~ : TabStyle = TabStyle::Box
) -> TabView {
  {
    base: @core.BaseRenderable::new(id),
    tabs: [],
    active_tab_index: 0,
    tab_position,
    tab_style,
    tab_width: None,
    show_overflow_arrows: true,
    scroll_offset: 0,
    active_tab_color: @core.RGBA::white(),
    inactive_tab_color: @core.RGBA::gray(),
    tab_background: @core.RGBA::new(0.1, 0.1, 0.1, 1.0),
    border_style: @core.BorderStyle::Single,
    border_color: @core.RGBA::gray(),
    focused: false,
  }
}

pub fn Tab::new(
  id : String,
  label : String,
  content : @core.BaseRenderable,
  closable~ : Bool = false,
  icon~ : String? = None,
  badge~ : String? = None
) -> Tab {
  {
    id,
    label,
    content,
    closable,
    icon,
    badge,
    visible: true,
  }
}

/// Add a tab
pub fn TabView::add_tab(self : TabView, tab : Tab) -> TabView {
  self.tabs.push(tab)
  self
}

/// Add a tab with simpler syntax
pub fn TabView::add(self : TabView, label : String, content : @core.BaseRenderable) -> TabView {
  self.add_tab(Tab::new(label + "_tab", label, content))
}

/// Remove a tab by index
pub fn TabView::remove_tab(self : TabView, index : Int) -> Unit {
  if index >= 0 && index < self.tabs.length() {
    let new_tabs = []
    for i = 0; i < self.tabs.length(); i = i + 1 {
      if i != index {
        new_tabs.push(self.tabs[i])
      }
    }
    self.tabs = new_tabs
    
    // Adjust active tab index
    if self.active_tab_index >= self.tabs.length() && self.tabs.length() > 0 {
      self.active_tab_index = self.tabs.length() - 1
    }
  }
}

/// Select next tab
pub fn TabView::next_tab(self : TabView) -> Unit {
  if self.tabs.length() > 0 {
    self.active_tab_index = (self.active_tab_index + 1) % self.tabs.length()
    self.ensure_tab_visible()
  }
}

/// Select previous tab
pub fn TabView::previous_tab(self : TabView) -> Unit {
  if self.tabs.length() > 0 {
    self.active_tab_index = if self.active_tab_index == 0 {
      self.tabs.length() - 1
    } else {
      self.active_tab_index - 1
    }
    self.ensure_tab_visible()
  }
}

/// Select a specific tab
pub fn TabView::select_tab(self : TabView, index : Int) -> Unit {
  if index >= 0 && index < self.tabs.length() {
    self.active_tab_index = index
    self.ensure_tab_visible()
  }
}

/// Select tab by ID
pub fn TabView::select_tab_by_id(self : TabView, id : String) -> Unit {
  for i = 0; i < self.tabs.length(); i = i + 1 {
    if self.tabs[i].id == id {
      self.select_tab(i)
      return
    }
  }
}

/// Ensure active tab is visible when scrolling
fn ensure_tab_visible(self : TabView) -> Unit {
  // This would calculate if the active tab is visible
  // and adjust scroll_offset if needed
  // Implementation depends on tab widths and viewport
}

/// Calculate tab bar dimensions
fn calculate_tab_bar_dimensions(self : TabView) -> (Int, Int, Int, Int) {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height
  
  match self.tab_position {
    TabPosition::Top => (x, y, width, 3)
    TabPosition::Bottom => (x, y + height - 3, width, 3)
    TabPosition::Left => (x, y, 15, height)
    TabPosition::Right => (x + width - 15, y, 15, height)
  }
}

/// Calculate content area dimensions
fn calculate_content_area(self : TabView) -> (Int, Int, Int, Int) {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  let width = self.base.width
  let height = self.base.height
  
  match self.tab_position {
    TabPosition::Top => (x, y + 3, width, height - 3)
    TabPosition::Bottom => (x, y, width, height - 3)
    TabPosition::Left => (x + 15, y, width - 15, height)
    TabPosition::Right => (x, y, width - 15, height)
  }
}

/// Get the base renderable with render function
pub fn TabView::as_renderable(self : TabView) -> @core.BaseRenderable {
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      self.render_tabview(buffer)
    })
  }
  self.base
}

/// Render the tab view
fn render_tabview(self : TabView, buffer : @core.TerminalBuffer) -> Unit {
  // Fill background
  if self.base.background_color != @core.RGBA::black() {
    buffer.fill_rect(
      self.base.absolute_x(),
      self.base.absolute_y(),
      self.base.width,
      self.base.height,
      ' ',
      self.base.foreground_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }
  
  // Render tab bar
  self.render_tab_bar(buffer)
  
  // Render content area with border
  self.render_content_area(buffer)
  
  // Render active tab content
  if self.active_tab_index >= 0 && self.active_tab_index < self.tabs.length() {
    let tab = self.tabs[self.active_tab_index]
    if tab.visible {
      let (cx, cy, cw, ch) = self.calculate_content_area()
      
      // Adjust for border
      let content_x = cx + 1
      let content_y = cy + 1
      let content_width = cw - 2
      let content_height = ch - 2
      
      tab.content.x = content_x
      tab.content.y = content_y
      tab.content.width = content_width
      tab.content.height = content_height
      tab.content.render(buffer)
    }
  }
}

/// Render the tab bar
fn render_tab_bar(self : TabView, buffer : @core.TerminalBuffer) -> Unit {
  let (bar_x, bar_y, bar_width, bar_height) = self.calculate_tab_bar_dimensions()
  
  // Fill tab bar background
  buffer.fill_rect(
    bar_x,
    bar_y,
    bar_width,
    bar_height,
    ' ',
    self.inactive_tab_color,
    self.tab_background,
    @core.TextStyle::None,
  )
  
  // Render tabs
  match self.tab_position {
    TabPosition::Top | TabPosition::Bottom => self.render_horizontal_tabs(buffer, bar_x, bar_y, bar_width)
    TabPosition::Left | TabPosition::Right => self.render_vertical_tabs(buffer, bar_x, bar_y, bar_height)
  }
}

/// Render horizontal tabs
fn render_horizontal_tabs(self : TabView, buffer : @core.TerminalBuffer, x : Int, y : Int, width : Int) -> Unit {
  let mut current_x = x + self.scroll_offset
  
  for i = 0; i < self.tabs.length(); i = i + 1 {
    let tab = self.tabs[i]
    if not(tab.visible) {
      continue
    }
    
    let is_active = i == self.active_tab_index
    let tab_color = if is_active { self.active_tab_color } else { self.inactive_tab_color }
    let tab_bg = if is_active { self.base.background_color } else { self.tab_background }
    
    // Calculate tab width
    let tab_width = match self.tab_width {
      Some(w) => w
      None => {
        let base_width = tab.label.length() + 4  // Padding
        let icon_width = match tab.icon {
          Some(icon) => icon.length() + 1
          None => 0
        }
        let badge_width = match tab.badge {
          Some(badge) => badge.length() + 2
          None => 0
        }
        let close_width = if tab.closable { 3 } else { 0 }
        base_width + icon_width + badge_width + close_width
      }
    }
    
    // Skip if tab is outside visible area
    if current_x + tab_width < x || current_x >= x + width {
      current_x = current_x + tab_width
      continue
    }
    
    // Render tab based on style
    match self.tab_style {
      TabStyle::Box => {
        // Top border
        buffer.write_char(current_x, y, '┌', tab_color, tab_bg, @core.TextStyle::None)
        for j = 1; j < tab_width - 1; j = j + 1 {
          buffer.write_char(current_x + j, y, '─', tab_color, tab_bg, @core.TextStyle::None)
        }
        buffer.write_char(current_x + tab_width - 1, y, '┐', tab_color, tab_bg, @core.TextStyle::None)
        
        // Middle with text
        buffer.write_char(current_x, y + 1, '│', tab_color, tab_bg, @core.TextStyle::None)
        
        let mut text_x = current_x + 2
        
        // Icon
        match tab.icon {
          Some(icon) => {
            buffer.write_string(text_x, y + 1, icon, tab_color, tab_bg, @core.TextStyle::None)
            text_x = text_x + icon.length() + 1
          }
          None => ()
        }
        
        // Label
        buffer.write_string(text_x, y + 1, tab.label, tab_color, tab_bg, 
          if is_active { @core.TextStyle::Bold } else { @core.TextStyle::None })
        text_x = text_x + tab.label.length()
        
        // Badge
        match tab.badge {
          Some(badge) => {
            buffer.write_string(text_x + 1, y + 1, "[" + badge + "]", tab_color, tab_bg, @core.TextStyle::None)
            text_x = text_x + badge.length() + 3
          }
          None => ()
        }
        
        // Close button
        if tab.closable {
          buffer.write_string(current_x + tab_width - 3, y + 1, " × ", 
            @core.RGBA::red(), tab_bg, @core.TextStyle::None)
        }
        
        buffer.write_char(current_x + tab_width - 1, y + 1, '│', tab_color, tab_bg, @core.TextStyle::None)
        
        // Bottom (connected to content for active tab)
        if is_active && self.tab_position == TabPosition::Top {
          for j = 1; j < tab_width - 1; j = j + 1 {
            buffer.write_char(current_x + j, y + 2, ' ', tab_color, tab_bg, @core.TextStyle::None)
          }
        } else {
          buffer.write_char(current_x, y + 2, '└', tab_color, tab_bg, @core.TextStyle::None)
          for j = 1; j < tab_width - 1; j = j + 1 {
            buffer.write_char(current_x + j, y + 2, '─', tab_color, tab_bg, @core.TextStyle::None)
          }
          buffer.write_char(current_x + tab_width - 1, y + 2, '┘', tab_color, tab_bg, @core.TextStyle::None)
        }
      }
      
      TabStyle::Underline => {
        // Simple underline style
        let mut text_x = current_x + 1
        
        // Render tab content
        match tab.icon {
          Some(icon) => {
            buffer.write_string(text_x, y + 1, icon, tab_color, tab_bg, @core.TextStyle::None)
            text_x = text_x + icon.length() + 1
          }
          None => ()
        }
        
        buffer.write_string(text_x, y + 1, tab.label, tab_color, tab_bg,
          if is_active { @core.TextStyle::Bold } else { @core.TextStyle::None })
        
        // Underline for active tab
        if is_active {
          for j = 0; j < tab_width; j = j + 1 {
            buffer.write_char(current_x + j, y + 2, '─', self.active_tab_color, tab_bg, @core.TextStyle::None)
          }
        }
      }
      
      _ => {
        // Simple style - just text
        let mut text_x = current_x + 1
        match tab.icon {
          Some(icon) => {
            buffer.write_string(text_x, y + 1, icon, tab_color, tab_bg, @core.TextStyle::None)
            text_x = text_x + icon.length() + 1
          }
          None => ()
        }
        buffer.write_string(text_x, y + 1, tab.label, tab_color, tab_bg,
          if is_active { @core.TextStyle::Bold } else { @core.TextStyle::None })
      }
    }
    
    current_x = current_x + tab_width
  }
}

/// Render vertical tabs
fn render_vertical_tabs(self : TabView, buffer : @core.TerminalBuffer, x : Int, y : Int, height : Int) -> Unit {
  let mut current_y = y + self.scroll_offset
  
  for i = 0; i < self.tabs.length(); i = i + 1 {
    let tab = self.tabs[i]
    if not(tab.visible) {
      continue
    }
    
    let is_active = i == self.active_tab_index
    let tab_color = if is_active { self.active_tab_color } else { self.inactive_tab_color }
    let tab_bg = if is_active { self.base.background_color } else { self.tab_background }
    
    // Skip if outside visible area
    if current_y >= y + height {
      break
    }
    
    if current_y >= y {
      // Render tab label
      let label = if tab.label.length() > 13 {
        let mut truncated = ""
        for i = 0; i < 10 && i < tab.label.length(); i = i + 1 {
          truncated = truncated + tab.label[i].to_string()
        }
        truncated + "..."
      } else {
        tab.label
      }
      
      buffer.write_string(x + 1, current_y, label, tab_color, tab_bg,
        if is_active { @core.TextStyle::Bold } else { @core.TextStyle::None })
      
      // Render selection indicator
      if is_active {
        buffer.write_char(x + 14, current_y, '▶', self.active_tab_color, tab_bg, @core.TextStyle::None)
      }
    }
    
    current_y = current_y + 1
  }
}

/// Render content area with border
fn render_content_area(self : TabView, buffer : @core.TerminalBuffer) -> Unit {
  let (x, y, width, height) = self.calculate_content_area()
  
  // Draw border around content area
  let border_chars = match self.border_style {
    @core.BorderStyle::None => (' ', ' ', ' ', ' ', ' ', ' ')
    @core.BorderStyle::Single => ('─', '│', '┌', '┐', '└', '┘')
    @core.BorderStyle::Double => ('═', '║', '╔', '╗', '╚', '╝')
    @core.BorderStyle::Thick => ('━', '┃', '┏', '┓', '┗', '┛')
    @core.BorderStyle::Rounded => ('─', '│', '╭', '╮', '╰', '╯')
    @core.BorderStyle::Dashed => ('┄', '┆', '┌', '┐', '└', '┘')
    @core.BorderStyle::Dotted => ('┈', '┊', '┌', '┐', '└', '┘')
  }
  
  let (h_line, v_line, top_left, top_right, bottom_left, bottom_right) = border_chars
  
  // Corners
  buffer.write_char(x, y, top_left, self.border_color, self.base.background_color, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y, top_right, self.border_color, self.base.background_color, @core.TextStyle::None)
  buffer.write_char(x, y + height - 1, bottom_left, self.border_color, self.base.background_color, @core.TextStyle::None)
  buffer.write_char(x + width - 1, y + height - 1, bottom_right, self.border_color, self.base.background_color, @core.TextStyle::None)
  
  // Horizontal lines
  for i = 1; i < width - 1; i = i + 1 {
    buffer.write_char(x + i, y, h_line, self.border_color, self.base.background_color, @core.TextStyle::None)
    buffer.write_char(x + i, y + height - 1, h_line, self.border_color, self.base.background_color, @core.TextStyle::None)
  }
  
  // Vertical lines
  for i = 1; i < height - 1; i = i + 1 {
    buffer.write_char(x, y + i, v_line, self.border_color, self.base.background_color, @core.TextStyle::None)
    buffer.write_char(x + width - 1, y + i, v_line, self.border_color, self.base.background_color, @core.TextStyle::None)
  }
}

/// Helper to set dimensions
pub fn TabView::with_dimensions(self : TabView, x : Int, y : Int, width : Int, height : Int) -> TabView {
  { ..self, base: { ..self.base, x, y, width, height } }
}

/// Set tab colors
pub fn TabView::with_tab_colors(self : TabView, active : @core.RGBA, inactive : @core.RGBA) -> TabView {
  { ..self, active_tab_color: active, inactive_tab_color: inactive }
}

/// Set fixed tab width
pub fn TabView::with_fixed_tab_width(self : TabView, width : Int) -> TabView {
  { ..self, tab_width: Some(width) }
}

/// Handle keyboard navigation
pub fn TabView::handle_key(self : TabView, key : String) -> Bool {
  match key {
    "Tab" | "ArrowRight" => {
      self.next_tab()
      true
    }
    "Shift+Tab" | "ArrowLeft" => {
      self.previous_tab()
      true
    }
    _ => false
  }
}