///| Minimal Focus Manager for keyboard navigation

pub struct FocusManager {
  mut focused : Int?
  mut count : Int
}

pub fn FocusManager::new(count : Int) -> FocusManager {
  { focused: if count > 0 { Some(0) } else { None }, count }
}

pub fn FocusManager::set_count(self : FocusManager, count : Int) -> Unit {
  self.count = count
  self.ensure_valid()
}

pub fn FocusManager::focus(self : FocusManager, index : Int) -> Unit {
  if index >= 0 && index < self.count { self.focused = Some(index) }
}

pub fn FocusManager::blur(self : FocusManager) -> Unit { self.focused = None }

pub fn FocusManager::next(self : FocusManager) -> Unit {
  match self.focused {
    None => if self.count > 0 { self.focused = Some(0) } else { () }
    Some(i) => {
      if self.count == 0 { self.focused = None }
      else if i + 1 < self.count { self.focused = Some(i + 1) }
      else { self.focused = Some(0) } // wrap
    }
  }
}

pub fn FocusManager::prev(self : FocusManager) -> Unit {
  match self.focused {
    None => if self.count > 0 { self.focused = Some(0) } else { () }
    Some(i) => {
      if self.count == 0 { self.focused = None }
      else if i > 0 { self.focused = Some(i - 1) }
      else { self.focused = Some(self.count - 1) } // wrap
    }
  }
}

pub fn FocusManager::is_focused(self : FocusManager, index : Int) -> Bool {
  match self.focused {
    Some(i) => i == index
    None => false
  }
}

pub fn FocusManager::get_focused(self : FocusManager) -> Int? { self.focused }

fn FocusManager::ensure_valid(self : FocusManager) -> Unit {
  match self.focused {
    None => ()
    Some(i) => if i < 0 || i >= self.count { self.focused = if self.count > 0 { Some(0) } else { None } } else { () }
  }
}
