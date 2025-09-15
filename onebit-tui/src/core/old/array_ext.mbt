///|
/// Array utility functions for OneBit TUI

///| Remove element at index
pub fn[T] array_remove(arr : Array[T], index : Int) -> Unit {
  if index < 0 || index >= arr.length() {
    return
  }
  
  // Shift elements left
  for i = index; i < arr.length() - 1; i = i + 1 {
    arr[i] = arr[i + 1]
  }
  
  // Remove last element
  let _ = arr.pop()
}

///| Append all elements from another array
pub fn[T] array_append(dest : Array[T], src : Array[T]) -> Unit {
  for i = 0; i < src.length(); i = i + 1 {
    dest.push(src[i])
  }
}

///| Map array elements to new array
pub fn[T, U] array_map(arr : Array[T], f : (T) -> U) -> Array[U] {
  let result = []
  for i = 0; i < arr.length(); i = i + 1 {
    result.push(f(arr[i]))
  }
  result
}

///| Filter array elements
pub fn[T] array_filter(arr : Array[T], predicate : (T) -> Bool) -> Array[T] {
  let result = []
  for i = 0; i < arr.length(); i = i + 1 {
    if predicate(arr[i]) {
      result.push(arr[i])
    }
  }
  result
}

///| Find first element matching predicate
pub fn[T] array_find(arr : Array[T], predicate : (T) -> Bool) -> Option[T] {
  for i = 0; i < arr.length(); i = i + 1 {
    if predicate(arr[i]) {
      return Some(arr[i])
    }
  }
  None
}

///| Check if any element matches predicate
pub fn[T] array_any(arr : Array[T], predicate : (T) -> Bool) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if predicate(arr[i]) {
      return true
    }
  }
  false
}

///| Check if all elements match predicate
pub fn[T] array_all(arr : Array[T], predicate : (T) -> Bool) -> Bool {
  for i = 0; i < arr.length(); i = i + 1 {
    if not(predicate(arr[i])) {
      return false
    }
  }
  true
}

///| Fold array elements
pub fn[T, U] array_fold(arr : Array[T], init : U, f : (U, T) -> U) -> U {
  let mut acc = init
  for i = 0; i < arr.length(); i = i + 1 {
    acc = f(acc, arr[i])
  }
  acc
}

/// Return the minimum of two integers
pub fn minimum(a : Int, b : Int) -> Int {
  if a < b { a } else { b }
}

/// Return the maximum of two integers  
pub fn maximum(a : Int, b : Int) -> Int {
  if a > b { a } else { b }
}