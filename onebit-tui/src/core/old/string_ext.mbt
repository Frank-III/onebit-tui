///|
/// String utility functions for OneBit TUI

///| Get substring from start to end index
pub fn string_substring(s : String, start : Int, end : Int) -> String {
  if start < 0 || start >= s.length() || end <= start {
    return ""
  }
  
  let actual_end = if end > s.length() { s.length() } else { end }
  let mut result = ""
  
  for i = start; i < actual_end; i = i + 1 {
    match s[i].to_char() {
      Some(ch) => result = result + ch.to_string()
      None => ()
    }
  }
  
  result
}

///| Check if string contains another string
pub fn string_contains(haystack : String, needle : String) -> Bool {
  if needle.length() == 0 {
    return true
  }
  if haystack.length() < needle.length() {
    return false
  }
  
  for i = 0; i <= haystack.length() - needle.length(); i = i + 1 {
    let mut matches = true
    for j = 0; j < needle.length(); j = j + 1 {
      if haystack[i + j] != needle[j] {
        matches = false
        break
      }
    }
    if matches {
      return true
    }
  }
  false
}

///| Repeat string n times
pub fn string_repeat(s : String, times : Int) -> String {
  let mut result = ""
  for i = 0; i < times; i = i + 1 {
    result = result + s
  }
  result
}

///| Trim whitespace from both ends
pub fn string_trim(s : String) -> String {
  let mut start = 0
  let mut end = s.length()
  
  // Find first non-whitespace
  while start < s.length() && is_whitespace(s[start]) {
    start = start + 1
  }
  
  // Find last non-whitespace
  while end > start && is_whitespace(s[end - 1]) {
    end = end - 1
  }
  
  string_substring(s, start, end)
}

fn is_whitespace(code : Int) -> Bool {
  code == 32 || code == 9 || code == 10 || code == 13  // space, tab, newline, carriage return
}