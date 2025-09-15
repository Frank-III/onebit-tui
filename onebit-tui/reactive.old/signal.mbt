///|
/// Signal-based reactive system inspired by SolidJS
/// Provides automatic dependency tracking and updates

///| Simple Ref type for mutable references
pub struct Ref[T] {
  mut val : T
}

pub fn[T] Ref::new(value : T) -> Ref[T] {
  { val: value }
}

///| Core signal type - a reactive value container
pub struct Signal[T] {
  mut value : T
  subscribers : Array[(T) -> Unit]
  id : Int
}

struct SignalIdCounter {
  mut value : Int
}

let signal_id_counter : SignalIdCounter = SignalIdCounter::{ value: 0 }

///| Create a new signal with initial value
pub fn[T] create_signal(initial : T) -> (Signal[T], (T) -> Unit) {
  signal_id_counter.value = signal_id_counter.value + 1
  let signal = {
    value: initial,
    subscribers: [],
    id: signal_id_counter.value
  }
  
  let setter = fn(new_value : T) {
    signal.value = new_value
    // Notify all subscribers (batched)
    let subscribers = signal.subscribers
    schedule_update(fn() {
      for i = 0; i < subscribers.length(); i = i + 1 {
        subscribers[i](new_value)
      }
    })
  }
  
  (signal, setter)
}

///| Get current value of signal
pub fn[T] Signal::get(self : Signal[T]) -> T {
  self.value
}

///| Update signal value using update function
pub fn[T] Signal::update(self : Signal[T], updater : (T) -> T) -> Unit {
  let new_value = updater(self.value)
  self.value = new_value
  // Notify subscribers
  for i = 0; i < self.subscribers.length(); i = i + 1 {
    self.subscribers[i](new_value)
  }
}

///| Subscribe to signal changes
pub fn[T] Signal::subscribe(self : Signal[T], callback : (T) -> Unit) -> Unit {
  self.subscribers.push(callback)
}

///| Computed signal - derives value from other signals
pub struct Computed[T] {
  compute : () -> T
  mut cached : T
  mut dirty : Bool
  dependencies : Array[Signal[Unit]]  // Type-erased dependencies
}

///| Create computed signal
pub fn[T] create_computed(compute : () -> T) -> Computed[T] {
  let initial = compute()
  {
    compute: compute,
    cached: initial,
    dirty: false,
    dependencies: []
  }
}

pub fn[T] Computed::get(self : Computed[T]) -> T {
  if self.dirty {
    self.cached = (self.compute)()
    self.dirty = false
  }
  self.cached
}

///| Effect - runs side effects when dependencies change
pub struct Effect {
  run : () -> Unit
  cleanup : Option[() -> Unit]
}

pub fn create_effect(effect_fn : () -> Unit) -> Effect {
  let effect : Effect = {
    run: effect_fn,
    cleanup: None
  }
  // Run immediately
  effect_fn()
  effect
}

///| Batch updates to prevent multiple renders
pub struct Batch {
  mut pending : Array[() -> Unit]
  mut is_batching : Bool
  mut scheduled : Bool
}

let global_batch : Ref[Batch] = Ref::new({
  pending: [],
  is_batching: false,
  scheduled: false
})

pub fn batch(updates : () -> Unit) -> Unit {
  let batch_ref = global_batch
  if batch_ref.val.is_batching {
    // Already batching, just run the updates
    updates()
  } else {
    // Start batching
    batch_ref.val.is_batching = true
    
    // Run the updates
    updates()
    
    // End batching and flush
    batch_ref.val.is_batching = false
    flush_batch()
  }
}

fn flush_batch() -> Unit {
  let batch_ref = global_batch
  let pending_updates = batch_ref.val.pending
  batch_ref.val.pending = []
  
  // Execute all pending updates
  for i = 0; i < pending_updates.length(); i = i + 1 {
    pending_updates[i]()
  }
}

///| Schedule an update to run later
pub fn schedule_update(update : () -> Unit) -> Unit {
  let batch_ref = global_batch
  if batch_ref.val.is_batching {
    // Add to pending updates
    batch_ref.val.pending.push(update)
  } else {
    // Run immediately
    update()
  }
}

///| Create a store for complex state
pub struct Store[T] {
  mut state : T
  listeners : Array[(T) -> Unit]
}

pub fn[T] create_store(initial : T) -> (Store[T], (T) -> Unit) {
  let store = {
    state: initial,
    listeners: []
  }
  
  let set_state = fn(new_state : T) {
    store.state = new_state
    for i = 0; i < store.listeners.length(); i = i + 1 {
      store.listeners[i](new_state)
    }
  }
  
  (store, set_state)
}

pub fn[T] Store::subscribe(self : Store[T], listener : (T) -> Unit) -> Unit {
  self.listeners.push(listener)
}

pub fn[T] Store::get(self : Store[T]) -> T {
  self.state
}