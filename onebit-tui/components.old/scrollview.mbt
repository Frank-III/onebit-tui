///| ScrollView Component
///| Provides scrollable viewport for content larger than visible area

pub(all) enum ScrollDirection {
  Vertical
  Horizontal
  Both
} derive(Eq)

pub(all) enum ScrollbarVisibility {
  Always
  Never
  Auto
} derive(Eq)

pub(all) struct ScrollView {
  mut base : @core.BaseRenderable
  mut content : @core.BaseRenderable
  mut scroll_x : Int
  mut scroll_y : Int
  mut viewport_width : Int
  mut viewport_height : Int
  direction : ScrollDirection
  scrollbar_visibility : ScrollbarVisibility
  mut show_vertical_scrollbar : Bool
  mut show_horizontal_scrollbar : Bool
  scrollbar_color : @core.RGBA
  scrollbar_track_color : @core.RGBA
  smooth_scroll : Bool
  mut scroll_speed : Int
}

pub fn ScrollView::new(
  id : String,
  content : @core.BaseRenderable,
  direction~ : ScrollDirection = ScrollDirection::Vertical,
  scrollbar_visibility~ : ScrollbarVisibility = ScrollbarVisibility::Auto,
  smooth_scroll~ : Bool = false
) -> ScrollView {
  {
    base: @core.BaseRenderable::new(id),
    content,
    scroll_x: 0,
    scroll_y: 0,
    viewport_width: 10,
    viewport_height: 10,
    direction,
    scrollbar_visibility,
    show_vertical_scrollbar: false,
    show_horizontal_scrollbar: false,
    scrollbar_color: @core.RGBA::gray(),
    scrollbar_track_color: @core.RGBA::new(0.2, 0.2, 0.2, 1.0),
    smooth_scroll,
    scroll_speed: 3,
  }
}

/// Calculate if scrollbars should be shown
pub fn ScrollView::update_scrollbar_visibility(self : ScrollView) -> Unit {
  let content_width = self.content.width
  let content_height = self.content.height
  
  match self.scrollbar_visibility {
    ScrollbarVisibility::Always => {
      self.show_vertical_scrollbar = self.direction == ScrollDirection::Vertical || 
                                     self.direction == ScrollDirection::Both
      self.show_horizontal_scrollbar = self.direction == ScrollDirection::Horizontal || 
                                       self.direction == ScrollDirection::Both
    }
    ScrollbarVisibility::Never => {
      self.show_vertical_scrollbar = false
      self.show_horizontal_scrollbar = false
    }
    ScrollbarVisibility::Auto => {
      self.show_vertical_scrollbar = (self.direction == ScrollDirection::Vertical || 
                                      self.direction == ScrollDirection::Both) &&
                                     content_height > self.viewport_height
      self.show_horizontal_scrollbar = (self.direction == ScrollDirection::Horizontal || 
                                        self.direction == ScrollDirection::Both) &&
                                       content_width > self.viewport_width
    }
  }
}

/// Scroll up
pub fn ScrollView::scroll_up(self : ScrollView, lines~ : Int = 1) -> Unit {
  if self.direction == ScrollDirection::Vertical || self.direction == ScrollDirection::Both {
    self.scroll_y = if self.scroll_y - lines * self.scroll_speed < 0 {
      0
    } else {
      self.scroll_y - lines * self.scroll_speed
    }
  }
}

/// Scroll down
pub fn ScrollView::scroll_down(self : ScrollView, lines~ : Int = 1) -> Unit {
  if self.direction == ScrollDirection::Vertical || self.direction == ScrollDirection::Both {
    let max_scroll = self.content.height - self.viewport_height
    if max_scroll > 0 {
      self.scroll_y = if self.scroll_y + lines * self.scroll_speed > max_scroll {
        max_scroll
      } else {
        self.scroll_y + lines * self.scroll_speed
      }
    }
  }
}

/// Scroll left
pub fn ScrollView::scroll_left(self : ScrollView, columns~ : Int = 1) -> Unit {
  if self.direction == ScrollDirection::Horizontal || self.direction == ScrollDirection::Both {
    self.scroll_x = if self.scroll_x - columns * self.scroll_speed < 0 {
      0
    } else {
      self.scroll_x - columns * self.scroll_speed
    }
  }
}

/// Scroll right
pub fn ScrollView::scroll_right(self : ScrollView, columns~ : Int = 1) -> Unit {
  if self.direction == ScrollDirection::Horizontal || self.direction == ScrollDirection::Both {
    let max_scroll = self.content.width - self.viewport_width
    if max_scroll > 0 {
      self.scroll_x = if self.scroll_x + columns * self.scroll_speed > max_scroll {
        max_scroll
      } else {
        self.scroll_x + columns * self.scroll_speed
      }
    }
  }
}

/// Scroll to top
pub fn ScrollView::scroll_to_top(self : ScrollView) -> Unit {
  self.scroll_y = 0
}

/// Scroll to bottom
pub fn ScrollView::scroll_to_bottom(self : ScrollView) -> Unit {
  let max_scroll = self.content.height - self.viewport_height
  if max_scroll > 0 {
    self.scroll_y = max_scroll
  }
}

/// Scroll to specific position
pub fn ScrollView::scroll_to(self : ScrollView, x : Int, y : Int) -> Unit {
  let max_scroll_x = self.content.width - self.viewport_width
  let max_scroll_y = self.content.height - self.viewport_height
  
  self.scroll_x = if x < 0 {
    0
  } else if x > max_scroll_x && max_scroll_x > 0 {
    max_scroll_x
  } else {
    x
  }
  
  self.scroll_y = if y < 0 {
    0
  } else if y > max_scroll_y && max_scroll_y > 0 {
    max_scroll_y
  } else {
    y
  }
}

/// Page up
pub fn ScrollView::page_up(self : ScrollView) -> Unit {
  self.scroll_up(lines=self.viewport_height - 1)
}

/// Page down
pub fn ScrollView::page_down(self : ScrollView) -> Unit {
  self.scroll_down(lines=self.viewport_height - 1)
}

/// Get the base renderable with render function
pub fn ScrollView::as_renderable(self : ScrollView) -> @core.BaseRenderable {
  if self.base.render_fn is None {
    self.base.set_render_fn(fn(base, buffer) {
      self.render_scrollview(buffer)
    })
  }
  self.base
}

/// Render the scrollview
fn render_scrollview(self : ScrollView, buffer : @core.TerminalBuffer) -> Unit {
  let x = self.base.absolute_x()
  let y = self.base.absolute_y()
  
  // Update viewport dimensions
  self.viewport_width = self.base.width
  self.viewport_height = self.base.height
  
  // Adjust for scrollbars
  if self.show_vertical_scrollbar {
    self.viewport_width = self.viewport_width - 1
  }
  if self.show_horizontal_scrollbar {
    self.viewport_height = self.viewport_height - 1
  }
  
  // Update scrollbar visibility
  self.update_scrollbar_visibility()
  
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
  
  // Create a viewport buffer for clipping
  // We'll render the content offset by scroll position
  // and only show what fits in the viewport
  
  // Save original content position
  let original_x = self.content.x
  let original_y = self.content.y
  
  // Temporarily adjust content position for scrolling
  self.content.x = x - self.scroll_x
  self.content.y = y - self.scroll_y
  
  // Set up clipping region (simplified - just don't render outside viewport)
  // In a real implementation, we'd use a separate buffer or clipping mask
  let clip_x = x
  let clip_y = y
  let clip_width = self.viewport_width
  let clip_height = self.viewport_height
  
  // Render content (with clipping in mind)
  // Note: This is simplified - proper clipping would require buffer manipulation
  self.content.render(buffer)
  
  // Restore original content position
  self.content.x = original_x
  self.content.y = original_y
  
  // Render scrollbars
  if self.show_vertical_scrollbar {
    self.render_vertical_scrollbar(buffer, x + self.viewport_width, y, self.base.height)
  }
  
  if self.show_horizontal_scrollbar {
    self.render_horizontal_scrollbar(buffer, x, y + self.viewport_height, self.viewport_width)
  }
}

/// Render vertical scrollbar
fn render_vertical_scrollbar(self : ScrollView, buffer : @core.TerminalBuffer, x : Int, y : Int, height : Int) -> Unit {
  // Draw track
  for i = 0; i < height; i = i + 1 {
    buffer.write_char(
      x,
      y + i,
      '│',
      self.scrollbar_track_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }
  
  // Calculate thumb position and size
  let content_height = self.content.height
  if content_height > self.viewport_height {
    let thumb_height = if self.viewport_height * height / content_height < 1 {
      1
    } else {
      self.viewport_height * height / content_height
    }
    
    let thumb_position = self.scroll_y * height / content_height
    
    // Draw thumb
    for i = 0; i < thumb_height && thumb_position + i < height; i = i + 1 {
      buffer.write_char(
        x,
        y + thumb_position + i,
        '█',
        self.scrollbar_color,
        self.base.background_color,
        @core.TextStyle::None,
      )
    }
  }
}

/// Render horizontal scrollbar
fn render_horizontal_scrollbar(self : ScrollView, buffer : @core.TerminalBuffer, x : Int, y : Int, width : Int) -> Unit {
  // Draw track
  for i = 0; i < width; i = i + 1 {
    buffer.write_char(
      x + i,
      y,
      '─',
      self.scrollbar_track_color,
      self.base.background_color,
      @core.TextStyle::None,
    )
  }
  
  // Calculate thumb position and size
  let content_width = self.content.width
  if content_width > self.viewport_width {
    let thumb_width = if self.viewport_width * width / content_width < 1 {
      1
    } else {
      self.viewport_width * width / content_width
    }
    
    let thumb_position = self.scroll_x * width / content_width
    
    // Draw thumb
    for i = 0; i < thumb_width && thumb_position + i < width; i = i + 1 {
      buffer.write_char(
        x + thumb_position + i,
        y,
        '█',
        self.scrollbar_color,
        self.base.background_color,
        @core.TextStyle::None,
      )
    }
  }
}

/// Helper to set dimensions
pub fn ScrollView::with_dimensions(self : ScrollView, x : Int, y : Int, width : Int, height : Int) -> ScrollView {
  { ..self, base: { ..self.base, x, y, width, height } }
}

/// Helper to set scrollbar colors
pub fn ScrollView::with_scrollbar_color(self : ScrollView, color : @core.RGBA) -> ScrollView {
  { ..self, scrollbar_color: color }
}

pub fn ScrollView::with_scrollbar_track_color(self : ScrollView, color : @core.RGBA) -> ScrollView {
  { ..self, scrollbar_track_color: color }
}

/// Set scroll speed
pub fn ScrollView::with_scroll_speed(self : ScrollView, speed : Int) -> ScrollView {
  self.scroll_speed = speed
  self
}

/// Handle mouse wheel events
pub fn ScrollView::handle_mouse_wheel(self : ScrollView, delta_x : Int, delta_y : Int) -> Unit {
  if delta_y != 0 {
    if delta_y > 0 {
      self.scroll_up(lines=delta_y)
    } else {
      self.scroll_down(lines=-delta_y)
    }
  }
  
  if delta_x != 0 {
    if delta_x > 0 {
      self.scroll_left(columns=delta_x)
    } else {
      self.scroll_right(columns=-delta_x)
    }
  }
}