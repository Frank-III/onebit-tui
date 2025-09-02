///|
/// Simple Map implementation for OneBit TUI
/// Provides key-value storage with string keys

pub struct Map[V] {
  mut entries : Array[(String, V)]
}

pub fn[V] Map::new() -> Map[V] {
  { entries: [] }
}

pub fn[V] Map::get(self : Map[V], key : String) -> Option[V] {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, v) = self.entries[i]
    if k == key {
      return Some(v)
    }
  }
  None
}

pub fn[V] Map::set(self : Map[V], key : String, value : V) -> Unit {
  // Check if key exists
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, _) = self.entries[i]
    if k == key {
      self.entries[i] = (key, value)
      return
    }
  }
  // Add new entry
  self.entries.push((key, value))
}

pub fn[V] Map::has(self : Map[V], key : String) -> Bool {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, _) = self.entries[i]
    if k == key {
      return true
    }
  }
  false
}

pub fn[V] Map::remove(self : Map[V], key : String) -> Option[V] {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, v) = self.entries[i]
    if k == key {
      // Remove by shifting elements
      for j = i; j < self.entries.length() - 1; j = j + 1 {
        self.entries[j] = self.entries[j + 1]
      }
      let _ = self.entries.pop()
      return Some(v)
    }
  }
  None
}

pub fn[V] Map::keys(self : Map[V]) -> Array[String] {
  let keys = []
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, _) = self.entries[i]
    keys.push(k)
  }
  keys
}

pub fn[V] Map::values(self : Map[V]) -> Array[V] {
  let values = []
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (_, v) = self.entries[i]
    values.push(v)
  }
  values
}

pub fn[V] Map::size(self : Map[V]) -> Int {
  self.entries.length()
}

pub fn[V] Map::clear(self : Map[V]) -> Unit {
  self.entries = []
}

pub fn[V] Map::each(self : Map[V], f : (String, V) -> Unit) -> Unit {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, v) = self.entries[i]
    f(k, v)
  }
}

pub fn[V] Map::is_empty(self : Map[V]) -> Bool {
  self.entries.length() == 0
}