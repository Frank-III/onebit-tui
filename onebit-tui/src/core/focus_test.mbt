///| Tests for FocusManager

test "focus manager basic traversal" {
  let fm = FocusManager::new(3)
  // Starts at 0
  match fm.get_focused() {
    Some(i) => inspect(i, content="0")
    None => assert_true(false)
  }
  fm.next()
  match fm.get_focused() {
    Some(i) => inspect(i, content="1")
    None => assert_true(false)
  }
  fm.next()
  match fm.get_focused() {
    Some(i) => inspect(i, content="2")
    None => assert_true(false)
  }
  fm.next()  // wrap
  match fm.get_focused() {
    Some(i) => inspect(i, content="0")
    None => assert_true(false)
  }
  fm.prev()  // wrap backwards
  match fm.get_focused() {
    Some(i) => inspect(i, content="2")
    None => assert_true(false)
  }
}

test "focus manager set_count clamps" {
  let fm = FocusManager::new(5)
  fm.focus(4)
  fm.set_count(2)
  match fm.get_focused() {
    Some(i) => assert_true(i >= 0 && i < 2)
    None => assert_true(false)
  }
  fm.set_count(0)
  match fm.get_focused() {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}
