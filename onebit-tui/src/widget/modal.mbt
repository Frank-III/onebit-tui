///|
/// Modal Component - Overlay dialogs with focus trap
pub struct Modal {
  content : &@view.Component       // The actual dialog content  
  mut title : String?               // Optional title
  mut width : Int?                  // Fixed width (chars) or auto
  mut height : Int?                 // Fixed height (lines) or auto
  mut backdrop : Bool               // Show dimmed background
  close_on_escape : Bool            // Close when Escape is pressed
  mut close_on_backdrop : Bool      // Close when clicking backdrop
  internal_focus : FocusManager // Modal's own focus manager
  mut on_close : (() -> Unit)?     // Callback when modal closes
}

///|
/// Create a new modal with content
pub fn Modal::new(content : &@view.Component) -> Modal {
  {
    content,
    title: None,
    width: None,
    height: None,
    backdrop: true,
    close_on_escape: true,
    close_on_backdrop: false,
    internal_focus: FocusManager::new(),
    on_close: None
  }
}

///|
/// Create a modal with a title
pub fn Modal::with_title(self : Modal, title : String) -> Modal {
  self.title = Some(title)
  self
}

///|
/// Set modal dimensions
pub fn Modal::with_size(self : Modal, width : Int, height : Int) -> Modal {
  self.width = Some(width)
  self.height = Some(height)
  self
}

///|
/// Set backdrop options
pub fn Modal::with_backdrop(self : Modal, show : Bool, close_on_click : Bool) -> Modal {
  self.backdrop = show
  self.close_on_backdrop = close_on_click
  self
}

///|
/// Set close callback
pub fn Modal::on_close(self : Modal, callback : () -> Unit) -> Modal {
  self.on_close = Some(callback)
  self
}

///|
/// Close this modal
pub fn Modal::close(self : Modal) -> Unit {
  // Call close callback if set
  match self.on_close {
    Some(callback) => callback()
    None => ()
  }
  
  // Remove from modal manager (returns focus to restore)
  let _ = ModalManager::pop_modal()
}

///|
/// Show this modal
pub fn Modal::show(self : Modal, current_focus : Int?) -> Unit {
  // Register focusable components within modal content
  self.scan_and_register_focusables()
  
  // Push to modal manager
  ModalManager::push_modal(self, current_focus)
}

///|
/// Scan content for focusable components and register them
fn Modal::scan_and_register_focusables(self : Modal) -> Unit {
  // For now, we'll rely on the content component's own focus handling
  // In the future, we could recursively scan for focusable children
  if self.content.is_focusable() {
    self.internal_focus.register("modal-content", self.content)
  }
}

///|
/// Component implementation for Modal
pub impl @view.Component for Modal with render(self) {
  let views : Array[@view.View] = []
  
  // Create backdrop if enabled
  if self.backdrop {
    let mut backdrop = @view.View::empty()
      .position(@view.Position::Absolute)
      .width(100.0)
      .height(100.0)
      .background(@core.Color::Black)
    
    // Add click handler if close_on_backdrop
    if self.close_on_backdrop {
      backdrop = backdrop.on_click(Some(fn(_x : Int, _y : Int) {
        self.close()
      }))
    }
    
    views.push(backdrop)
  }
  
  // Build modal content
  let content_components : Array[&@view.Component] = []
  
  // Add title if present
  match self.title {
    Some(title) => {
      // Create a text component for the title
      let title_component = Text::new(title)
      content_components.push(title_component)
    }
    None => ()
  }
  
  // Add the main content
  content_components.push(self.content)
  
  // Create container with all content
  let mut modal_with_content = @view.View::container(content_components)
    .position(@view.Position::Absolute)
    .background(@core.Color::Black)
    .border(@view.BorderStyle::Double, color=@core.Color::White)
    .padding(1.0)
  
  // Set size if specified
  match self.width {
    Some(w) => modal_with_content = modal_with_content.width(w.to_double())
    None => modal_with_content = modal_with_content.width(50.0)
  }
  
  match self.height {
    Some(h) => modal_with_content = modal_with_content.height(h.to_double())
    None => ()
  }
  
  // Center the modal
  modal_with_content = modal_with_content
    .align_items(@types.Align::Center)
    .justify_content(@types.Justify::Center)
  
  views.push(modal_with_content)
  
  // Return the complete modal view
  @view.View::container_views(views)
}

///|
pub impl @view.Component for Modal with handle_event(self, event) {
  match event {
    @events.Event::Key(key) =>
      match key {
        @ffi.KeyEvent::Tab => {
          // Handle Tab within modal (focus trap)
          let _ = self.internal_focus.focus_next()
          true  // Always consume Tab in modal
        }
        @ffi.KeyEvent::Escape if self.close_on_escape => {
          // Close the modal
          self.close()
          true
        }
        _ => {
          // Pass to modal's focused component
          self.internal_focus.handle_navigation(event)
        }
      }
    @events.Event::Mouse(_) =>
      // Pass mouse events to content
      self.content.handle_event(event)
    _ =>
      // Pass other events to content
      self.content.handle_event(event)
  }
}

///|
pub impl @view.Component for Modal with is_focusable(_self) {
  true  // Modal itself is focusable to trap focus
}

///|
/// Confirmation Dialog - A simple yes/no modal
pub struct ConfirmDialog {
  message : String
  on_confirm : () -> Unit
  mut on_cancel : (() -> Unit)?
  mut confirm_text : String
  mut cancel_text : String
}

///|
/// Create a confirmation dialog
pub fn ConfirmDialog::new(
  message : String,
  on_confirm : () -> Unit
) -> ConfirmDialog {
  {
    message,
    on_confirm,
    on_cancel: None,
    confirm_text: "Yes",
    cancel_text: "No"
  }
}

///|
/// Set cancel callback
pub fn ConfirmDialog::on_cancel(self : ConfirmDialog, callback : () -> Unit) -> ConfirmDialog {
  self.on_cancel = Some(callback)
  self
}

///|
/// Set button labels
pub fn ConfirmDialog::with_labels(
  self : ConfirmDialog,
  confirm : String,
  cancel : String
) -> ConfirmDialog {
  self.confirm_text = confirm
  self.cancel_text = cancel
  self
}

///|
/// Show the confirmation dialog
pub fn ConfirmDialog::show(self : ConfirmDialog, current_focus : Int?) -> Unit {
  // Create the dialog content
  let content = Column::new([
    Text::new(self.message),
    Row::new([
      Button::primary(self.confirm_text, fn() {
        // Close modal first
        let _ = ModalManager::pop_modal()
        // Then execute callback
        (self.on_confirm)()
      }),
      Button::secondary(self.cancel_text, fn() {
        // Close modal
        let _ = ModalManager::pop_modal()
        // Execute cancel callback if set
        match self.on_cancel {
          Some(callback) => callback()
          None => ()
        }
      })
    ]).spacing(2.0)
  ])
  
  // Create and show modal
  let modal = Modal::new(content)
    .with_title("Confirm")
    .with_backdrop(true, false)
  
  modal.show(current_focus)
}

///|
/// Component implementation for ConfirmDialog
pub impl @view.Component for ConfirmDialog with render(self) {
  // Create the content and wrap in a modal
  let content = Column::new([
    Text::new(self.message),
    Row::new([
      Button::primary(self.confirm_text, fn() {
        let _ = ModalManager::pop_modal()
        (self.on_confirm)()
      }),
      Button::secondary(self.cancel_text, fn() {
        let _ = ModalManager::pop_modal()
        match self.on_cancel {
          Some(callback) => callback()
          None => ()
        }
      })
    ]).spacing(2.0)
  ])
  
  Modal::new(content).with_title("Confirm").render()
}

///|
pub impl @view.Component for ConfirmDialog with handle_event(_self, _event) {
  false  // Let the modal handle events
}

///|
pub impl @view.Component for ConfirmDialog with is_focusable(_self) {
  false
}