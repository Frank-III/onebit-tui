///|
/// Option utility functions for OneBit TUI

///| Check if Option is Some
pub fn[T] option_is_some(opt : Option[T]) -> Bool {
  match opt {
    Some(_) => true
    None => false
  }
}

///| Check if Option is None
pub fn[T] option_is_none(opt : Option[T]) -> Bool {
  match opt {
    Some(_) => false
    None => true
  }
}

///| Unwrap Option, panic if None
pub fn[T] option_unwrap(opt : Option[T]) -> T {
  match opt {
    Some(value) => value
    None => abort("Called unwrap on None")
  }
}

///| Unwrap Option with default value
pub fn[T] option_unwrap_or(opt : Option[T], default : T) -> T {
  match opt {
    Some(value) => value
    None => default
  }
}

///| Map Option value
pub fn[T, U] option_map(opt : Option[T], f : (T) -> U) -> Option[U] {
  match opt {
    Some(value) => Some(f(value))
    None => None
  }
}

///| FlatMap Option value
pub fn[T, U] option_flat_map(opt : Option[T], f : (T) -> Option[U]) -> Option[U] {
  match opt {
    Some(value) => f(value)
    None => None
  }
}

///| Check if Option is empty (alias for is_none)
pub fn[T] option_is_empty(opt : Option[T]) -> Bool {
  option_is_none(opt)
}