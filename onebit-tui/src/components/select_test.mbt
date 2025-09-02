///| Tests for the Select component

test "Select::new creates component with default values" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false },
    SelectItem::{ label: "Item 2", value: "2", disabled: false }
  ]
  
  let select = Select::new(items)
  
  assert_eq(select.selected_index, -1)
  assert_eq(select.is_open, false)
  assert_eq(select.placeholder, "Select an option...")
  assert_eq(select.max_visible_items, 5)
  assert_eq(select.items.length(), 2)
}

test "Select::selected_item returns None when nothing selected" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  
  match select.selected_item() {
    None => assert_true(true)
    Some(_) => assert_true(false)
  }
}

test "Select::selected_item returns item when selected" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false },
    SelectItem::{ label: "Item 2", value: "2", disabled: false }
  ]
  
  let select = Select::new(items)
  select.selected_index = 1
  
  match select.selected_item() {
    Some(item) => {
      assert_eq(item.label, "Item 2")
      assert_eq(item.value, "2")
    }
    None => assert_true(false)
  }
}

test "Select::display_text shows placeholder when nothing selected" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items, placeholder="Pick one...")
  assert_eq(select.display_text(), "Pick one...")
}

test "Select::display_text shows selected item label" {
  let items = [
    SelectItem::{ label: "Apple", value: "apple", disabled: false },
    SelectItem::{ label: "Banana", value: "banana", disabled: false }
  ]
  
  let select = Select::new(items)
  select.selected_index = 0
  assert_eq(select.display_text(), "Apple")
}

test "Select::toggle changes is_open state" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  assert_eq(select.is_open, false)
  
  select.toggle()
  assert_eq(select.is_open, true)
  
  select.toggle()
  assert_eq(select.is_open, false)
}

test "Select::open sets is_open to true" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = false
  
  select.open()
  assert_eq(select.is_open, true)
}

test "Select::close sets is_open to false" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = true
  
  select.close()
  assert_eq(select.is_open, false)
}

test "Select::select_index updates selection and calls callback" {
  let mut callback_called = false
  let mut callback_value = ""
  
  let items = [
    SelectItem::{ label: "Apple", value: "apple", disabled: false },
    SelectItem::{ label: "Banana", value: "banana", disabled: false }
  ]
  
  let select = Select::new(
    items,
    on_change=Some(fn(value) -> Unit {
      callback_called = true
      callback_value = value
    })
  )
  
  select.is_open = true
  select.select_index(1)
  
  assert_eq(select.selected_index, 1)
  assert_eq(select.is_open, false) // Should close after selection
  assert_eq(callback_called, true)
  assert_eq(callback_value, "banana")
}

test "Select::select_index ignores disabled items" {
  let items = [
    SelectItem::{ label: "Apple", value: "apple", disabled: false },
    SelectItem::{ label: "Banana", value: "banana", disabled: true }
  ]
  
  let select = Select::new(items)
  select.select_index(1) // Try to select disabled item
  
  assert_eq(select.selected_index, -1) // Should remain unselected
}

test "Select::move_down skips disabled items" {
  let items = [
    SelectItem::{ label: "Apple", value: "apple", disabled: false },
    SelectItem::{ label: "Banana", value: "banana", disabled: true },
    SelectItem::{ label: "Cherry", value: "cherry", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = true
  select.selected_index = 0
  
  select.move_down()
  assert_eq(select.selected_index, 2) // Should skip disabled item at index 1
}

test "Select::move_up skips disabled items" {
  let items = [
    SelectItem::{ label: "Apple", value: "apple", disabled: false },
    SelectItem::{ label: "Banana", value: "banana", disabled: true },
    SelectItem::{ label: "Cherry", value: "cherry", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = true
  select.selected_index = 2
  
  select.move_up()
  assert_eq(select.selected_index, 0) // Should skip disabled item at index 1
}

test "Select::handle_key Enter toggles when closed" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  assert_eq(select.is_open, false)
  
  let handled = select.handle_key(@ffi.KeyEvent::Enter)
  assert_eq(handled, true)
  assert_eq(select.is_open, true)
}

test "Select::handle_key Enter selects item when open" {
  let items = [
    SelectItem::{ label: "Apple", value: "apple", disabled: false },
    SelectItem::{ label: "Banana", value: "banana", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = true
  select.selected_index = 1
  
  let handled = select.handle_key(@ffi.KeyEvent::Enter)
  assert_eq(handled, true)
  assert_eq(select.selected_index, 1)
  assert_eq(select.is_open, false)
}

test "Select::handle_key Escape closes dropdown" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = true
  
  let handled = select.handle_key(@ffi.KeyEvent::Escape)
  assert_eq(handled, true)
  assert_eq(select.is_open, false)
}

test "Select::handle_key ArrowDown opens when closed" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  assert_eq(select.is_open, false)
  
  let handled = select.handle_key(@ffi.KeyEvent::ArrowDown)
  assert_eq(handled, true)
  assert_eq(select.is_open, true)
}

test "Select::height returns 1 when closed" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false }
  ]
  
  let select = Select::new(items)
  select.is_open = false
  
  assert_eq(select.height(), 1)
}

test "Select::height returns dropdown height when open" {
  let items = [
    SelectItem::{ label: "Item 1", value: "1", disabled: false },
    SelectItem::{ label: "Item 2", value: "2", disabled: false },
    SelectItem::{ label: "Item 3", value: "3", disabled: false }
  ]
  
  let select = Select::new(items, max_visible_items=2)
  select.is_open = true
  
  assert_eq(select.height(), 3) // 1 for select box + 2 visible items
}