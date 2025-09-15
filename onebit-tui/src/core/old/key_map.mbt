///| KeyMap - A map implementation for Key -> Value mapping

pub struct KeyMap[V] {
  mut entries : Array[(Key, V)]
}

pub fn[V] KeyMap::new() -> KeyMap[V] {
  { entries: [] }
}

pub fn[V] KeyMap::get(self : KeyMap[V], key : Key) -> Option[V] {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, v) = self.entries[i]
    if k == key {
      return Some(v)
    }
  }
  None
}

pub fn[V] KeyMap::set(self : KeyMap[V], key : Key, value : V) -> Unit {
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

pub fn[V] KeyMap::has(self : KeyMap[V], key : Key) -> Bool {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, _) = self.entries[i]
    if k == key {
      return true
    }
  }
  false
}

pub fn[V] KeyMap::remove(self : KeyMap[V], key : Key) -> Option[V] {
  for i = 0; i < self.entries.length(); i = i + 1 {
    let (k, v) = self.entries[i]
    if k == key {
      // Remove by shifting elements
      let mut new_entries : Array[(Key, V)] = []
      for j = 0; j < self.entries.length(); j = j + 1 {
        if j != i {
          new_entries.push(self.entries[j])
        }
      }
      self.entries = new_entries
      return Some(v)
    }
  }
  None
}

pub fn[V] KeyMap::clear(self : KeyMap[V]) -> Unit {
  self.entries = []
}

pub fn[V] KeyMap::size(self : KeyMap[V]) -> Int {
  self.entries.length()
}