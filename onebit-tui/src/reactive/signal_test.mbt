///|
/// Tests for Signal-based reactive system
/// Verifies signal creation, updates, subscriptions, and effects

test "create_signal creates signal with initial value" {
  let (signal, _) = create_signal(42)
  inspect(signal.get(), content="42")
}

test "signal setter updates value" {
  let (signal, set_signal) = create_signal("hello")
  set_signal("world")
  inspect(signal.get(), content="world")
}

test "signal subscribers are notified on change" {
  let (signal, set_signal) = create_signal(10)
  let mut received = 0
  
  signal.subscribe(fn(value) {
    received = value
  })
  
  set_signal(20)
  inspect(received, content="20")
}

test "multiple subscribers all get notified" {
  let (signal, set_signal) = create_signal(0)
  let mut count1 = 0
  let mut count2 = 0
  let mut count3 = 0
  
  signal.subscribe(fn(value) { count1 = value })
  signal.subscribe(fn(value) { count2 = value })
  signal.subscribe(fn(value) { count3 = value })
  
  set_signal(100)
  
  inspect(count1, content="100")
  inspect(count2, content="100")
  inspect(count3, content="100")
}

test "signal update function modifies value" {
  let (signal, _) = create_signal(5)
  signal.update(fn(x) { x * 2 })
  inspect(signal.get(), content="10")
}

test "signal update notifies subscribers" {
  let (signal, _) = create_signal(3)
  let mut received = 0
  
  signal.subscribe(fn(value) {
    received = value
  })
  
  signal.update(fn(x) { x + 7 })
  inspect(received, content="10")
}

test "create_computed creates computed signal" {
  let computed = create_computed(fn() { 
    40 + 2
  })
  inspect(computed.get(), content="42")
}

test "computed caches value when not dirty" {
  let mut compute_count = 0
  let computed = create_computed(fn() {
    compute_count = compute_count + 1
    100
  })
  
  // First get computes
  let val1 = computed.get()
  // Second get should use cache
  let val2 = computed.get()
  
  inspect(val1, content="100")
  inspect(val2, content="100")
  inspect(compute_count, content="1")
}

test "create_effect runs immediately" {
  let mut effect_ran = false
  let _ = create_effect(fn() {
    effect_ran = true
  })
  inspect(effect_ran, content="true")
}

test "create_store creates store with initial state" {
  let (store, _) = create_store(42)
  inspect(store.get(), content="42")
}

test "store setter updates state" {
  let (store, set_store) = create_store("initial")
  set_store("updated")
  inspect(store.get(), content="updated")
}

test "store notifies listeners on change" {
  let (store, set_store) = create_store(1)
  let mut received = 0
  
  store.subscribe(fn(value) {
    received = value
  })
  
  set_store(2)
  inspect(received, content="2")
}

test "batch function executes updates" {
  let mut executed = false
  batch(fn() {
    executed = true
  })
  inspect(executed, content="true")
}

test "signal works with bool type" {
  let (bool_signal, set_bool) = create_signal(true)
  set_bool(false)
  inspect(bool_signal.get(), content="false")
}

test "signal works with double type" {
  let (double_signal, set_double) = create_signal(3.14)
  set_double(2.71)
  inspect(double_signal.get(), content="2.71")
}

test "signal works with array type" {
  let (array_signal, set_array) = create_signal([1, 2, 3])
  set_array([4, 5, 6])
  inspect(array_signal.get().length(), content="3")
  inspect(array_signal.get()[0], content="4")
}

test "signal subscription chain works" {
  let (signal1, set_signal1) = create_signal(10)
  let (signal2, set_signal2) = create_signal(20)
  let mut result = 0
  
  signal1.subscribe(fn(value) {
    // When signal1 changes, update signal2
    set_signal2(value * 2)
  })
  
  signal2.subscribe(fn(value) {
    result = value
  })
  
  set_signal1(5) // Should trigger signal2 to become 10
  inspect(result, content="10")
}

test "multiple signals can be composed" {
  let (width, set_width) = create_signal(10)
  let (height, set_height) = create_signal(20)
  let mut area = 0
  
  // Simulate a computed value that depends on both
  let compute_area = fn() {
    width.get() * height.get()
  }
  
  // Initial computation
  area = compute_area()
  inspect(area, content="200")
  
  // Update width
  set_width(15)
  area = compute_area()
  inspect(area, content="300")
  
  // Update height  
  set_height(30)
  area = compute_area()
  inspect(area, content="450")
}

test "reactive system handles signal ids" {
  let (signal1, _) = create_signal(1)
  let (signal2, _) = create_signal(2)
  let (signal3, _) = create_signal(3)
  
  // Each signal should have a unique ID
  inspect(signal1.id > 0, content="true")
  inspect(signal2.id > signal1.id, content="true")
  inspect(signal3.id > signal2.id, content="true")
}

test "effect returns effect structure" {
  let effect = create_effect(fn() {
    // Effect body
    let _ = 1 + 1
  })
  
  // Verify effect was created with proper structure
  inspect(effect.cleanup.is_empty(), content="true")
}

test "store handles string state" {
  let (store, set_store) = create_store("hello")
  
  let mut notifications = 0
  store.subscribe(fn(_) {
    notifications = notifications + 1
  })
  
  set_store("world")
  set_store("moon")
  set_store("bit")
  
  inspect(store.get(), content="bit")
  inspect(notifications, content="3")
}

test "computed signal dirty flag" {
  let computed = create_computed(fn() { 42 })
  
  // After creation, it's not dirty (already computed)
  inspect(computed.dirty, content="false")
  inspect(computed.cached, content="42")
}

test "signal array subscription" {
  let (signal, set_signal) = create_signal(0)
  
  // Add multiple subscribers
  signal.subscribe(fn(_) { })
  signal.subscribe(fn(_) { })
  signal.subscribe(fn(_) { })
  
  // Check that subscribers array has grown
  inspect(signal.subscribers.length(), content="3")
}

test "store array state" {
  let (store, set_store) = create_store([1, 2, 3])
  
  set_store([4, 5, 6, 7])
  inspect(store.get().length(), content="4")
  inspect(store.get()[0], content="4")
  inspect(store.get()[3], content="7")
}