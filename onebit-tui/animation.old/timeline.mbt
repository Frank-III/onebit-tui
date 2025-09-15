// Timeline-based animation system for OpenTUI MoonBit
// Fixed version with proper syntax

// Animation options
pub struct AnimationOptions {
  duration : Int          // Duration in milliseconds
  ease : EasingFunction
  on_update : Option[(Animation) -> Unit]
  on_complete : Option[() -> Unit]
  on_start : Option[() -> Unit]
  on_loop : Option[() -> Unit]
  loop : LoopOption
  loop_delay : Int
  alternate : Bool
  once : Bool
}

pub enum LoopOption {
  NoLoop
  Infinite
  Count(Int)
}

pub struct Animation {
  progress : Double
  current_time : Int
  delta_time : Int
}

// Timeline options
pub struct TimelineOptions {
  duration : Int
  loop : Bool
  autoplay : Bool
  on_complete : Option[() -> Unit]
  on_pause : Option[() -> Unit]
}

// Easing functions
pub enum EasingFunction {
  Linear
  InQuad
  OutQuad
  InOutQuad
  InExpo
  OutExpo
  InOutSine
  OutBounce
  OutElastic
  InBounce
  InCirc
  OutCirc
  InOutCirc
  InBack
  OutBack
  InOutBack
}

// Apply easing function
pub fn apply_easing(easing : EasingFunction, t : Double) -> Double {
  match easing {
    Linear => t
    InQuad => t * t
    OutQuad => t * (2.0 - t)
    InOutQuad => {
      if t < 0.5 {
        2.0 * t * t
      } else {
        -1.0 + (4.0 - 2.0 * t) * t
      }
    }
    InExpo => {
      if t == 0.0 { 0.0 } else { @math.pow(2.0, 10.0 * (t - 1.0)) }
    }
    OutExpo => {
      if t == 1.0 { 1.0 } else { 1.0 - @math.pow(2.0, -10.0 * t) }
    }
    InOutSine => {
      -(@math.cos(@math.pi * t) - 1.0) / 2.0
    }
    OutBounce => {
      let n1 = 7.5625
      let d1 = 2.75
      if t < 1.0 / d1 {
        n1 * t * t
      } else if t < 2.0 / d1 {
        let t2 = t - 1.5 / d1
        n1 * t2 * t2 + 0.75
      } else if t < 2.5 / d1 {
        let t2 = t - 2.25 / d1
        n1 * t2 * t2 + 0.9375
      } else {
        let t2 = t - 2.625 / d1
        n1 * t2 * t2 + 0.984375
      }
    }
    OutElastic => {
      if t == 0.0 { 
        0.0 
      } else if t == 1.0 { 
        1.0 
      } else {
        let c4 = (2.0 * @math.pi) / 3.0
        @math.pow(2.0, -10.0 * t) * @math.sin((t * 10.0 - 0.75) * c4) + 1.0
      }
    }
    InBounce => {
      1.0 - apply_easing(OutBounce, 1.0 - t)
    }
    InCirc => {
      1.0 - @math.sqrt(1.0 - t * t)
    }
    OutCirc => {
      let t1 = t - 1.0
      @math.sqrt(1.0 - t1 * t1)
    }
    InOutCirc => {
      let t2 = t * 2.0
      if t2 < 1.0 {
        -0.5 * (@math.sqrt(1.0 - t2 * t2) - 1.0)
      } else {
        let t3 = t2 - 2.0
        0.5 * (@math.sqrt(1.0 - t3 * t3) + 1.0)
      }
    }
    InBack => {
      let s = 1.70158
      t * t * ((s + 1.0) * t - s)
    }
    OutBack => {
      let s = 1.70158
      let t1 = t - 1.0
      t1 * t1 * ((s + 1.0) * t1 + s) + 1.0
    }
    InOutBack => {
      let s = 1.70158 * 1.525
      let t2 = t * 2.0
      if t2 < 1.0 {
        0.5 * (t2 * t2 * ((s + 1.0) * t2 - s))
      } else {
        let t3 = t2 - 2.0
        0.5 * (t3 * t3 * ((s + 1.0) * t3 + s) + 2.0)
      }
    }
  }
}

// Animation item
pub struct AnimationItem {
  mut start_time : Int
  mut duration : Int
  mut ease : EasingFunction
  mut loop : LoopOption
  mut loop_delay : Int
  mut alternate : Bool
  mut on_update : Option[(Animation) -> Unit]
  mut on_complete : Option[() -> Unit]
  mut on_start : Option[() -> Unit]
  mut on_loop : Option[() -> Unit]
  mut completed : Bool
  mut started : Bool
  mut current_loop : Int
  mut once : Bool
}

// Callback item
pub struct CallbackItem {
  start_time : Int
  callback : () -> Unit
  mut executed : Bool
}

// Timeline item types
pub enum TimelineItem {
  Animation(AnimationItem)
  Callback(CallbackItem)
}

// Main Timeline class
pub struct Timeline {
  mut items : Array[TimelineItem]
  mut current_time : Int
  mut is_playing : Bool
  mut is_complete : Bool
  duration : Int
  loop : Bool
  mut synced : Bool
  autoplay : Bool
  on_complete : Option[() -> Unit]
  on_pause : Option[() -> Unit]
}

pub fn Timeline::new(options : TimelineOptions) -> Timeline {
  {
    items: [],
    current_time: 0,
    is_playing: false,
    is_complete: false,
    duration: options.duration,
    loop: options.loop,
    synced: false,
    autoplay: options.autoplay,
    on_complete: options.on_complete,
    on_pause: options.on_pause,
  }
}

// Add animation to timeline
pub fn add_animation(
  self : Timeline,
  start_time : Int,
  options : AnimationOptions
) -> Timeline {
  let item = AnimationItem {
    start_time,
    duration: options.duration,
    ease: options.ease,
    loop: options.loop,
    loop_delay: options.loop_delay,
    alternate: options.alternate,
    on_update: options.on_update,
    on_complete: options.on_complete,
    on_start: options.on_start,
    on_loop: options.on_loop,
    completed: false,
    started: false,
    current_loop: 0,
    once: options.once,
  }
  
  self.items.push(Animation(item))
  self
}

// Add callback to timeline
pub fn call(self : Timeline, callback : () -> Unit, start_time : Int) -> Timeline {
  let item = CallbackItem {
    start_time,
    callback,
    executed: false,
  }
  
  self.items.push(Callback(item))
  self
}

// Play timeline
pub fn play(self : Timeline) -> Timeline {
  if self.is_complete {
    self.restart()
  } else {
    self.is_playing = true
    self
  }
}

// Pause timeline
pub fn pause(self : Timeline) -> Timeline {
  self.is_playing = false
  match self.on_pause {
    Some(callback) => callback()
    None => ()
  }
  self
}

// Restart timeline
pub fn restart(self : Timeline) -> Timeline {
  self.is_complete = false
  self.current_time = 0
  self.is_playing = true
  self.reset_items()
  self
}

// Reset all items
fn reset_items(self : Timeline) -> Unit {
  for item in self.items {
    match item {
      Callback(cb) => cb.executed = false
      Animation(anim) => {
        anim.completed = false
        anim.started = false
        anim.current_loop = 0
      }
    }
  }
}

// Update timeline
pub fn update(self : Timeline, delta_time : Int) -> Unit {
  if not(self.is_playing) {
    return
  }
  
  self.current_time = self.current_time + delta_time
  
  // Evaluate all items
  for item in self.items {
    match item {
      Animation(anim) => evaluate_animation(anim, self.current_time, delta_time)
      Callback(cb) => evaluate_callback(cb, self.current_time)
    }
  }
  
  // Check if timeline is complete
  if self.loop && self.current_time >= self.duration {
    let overshoot = self.current_time % self.duration
    self.reset_items()
    self.current_time = 0
    
    if overshoot > 0 {
      self.update(overshoot)
    }
  } else if not(self.loop) && self.current_time >= self.duration {
    self.current_time = self.duration
    self.is_playing = false
    self.is_complete = true
    
    match self.on_complete {
      Some(callback) => callback()
      None => ()
    }
  }
}

// Evaluate animation item
fn evaluate_animation(item : AnimationItem, timeline_time : Int, delta_time : Int) -> Unit {
  if timeline_time < item.start_time {
    return
  }
  
  let animation_time = timeline_time - item.start_time
  
  // Start animation
  if timeline_time >= item.start_time && not(item.started) {
    match item.on_start {
      Some(callback) => callback()
      None => ()
    }
    item.started = true
  }
  
  // Handle instant animations
  if item.duration == 0 {
    if not(item.completed) {
      apply_animation_at_progress(item, 1.0, false, timeline_time, delta_time)
      match item.on_complete {
        Some(callback) => callback()
        None => ()
      }
      item.completed = true
    }
    return
  }
  
  // Calculate loop info
  let max_loops = match item.loop {
    NoLoop => 1
    Count(n) => n
    Infinite => 999999  // Large number for "infinite"
  }
  
  let cycle_time = item.duration + item.loop_delay
  let current_cycle = animation_time / cycle_time
  let time_in_cycle = animation_time % cycle_time
  
  // Check if animation is complete
  if current_cycle >= max_loops {
    if not(item.completed) {
      let final_reversed = item.alternate && ((max_loops - 1) % 2 == 1)
      apply_animation_at_progress(item, 1.0, final_reversed, timeline_time, delta_time)
      
      match item.on_complete {
        Some(callback) => callback()
        None => ()
      }
      item.completed = true
    }
    return
  }
  
  // Apply animation
  if time_in_cycle < item.duration {
    let progress = time_in_cycle.to_double() / item.duration.to_double()
    let is_reversed = item.alternate && (current_cycle % 2 == 1)
    apply_animation_at_progress(item, progress, is_reversed, timeline_time, delta_time)
  }
}

// Apply animation at progress
fn apply_animation_at_progress(
  item : AnimationItem,
  progress : Double,
  reversed : Bool,
  timeline_time : Int,
  delta_time : Int
) -> Unit {
  let eased_progress = apply_easing(item.ease, @math.max(0.0, @math.min(1.0, progress)))
  let final_progress = if reversed { 1.0 - eased_progress } else { eased_progress }
  
  match item.on_update {
    Some(callback) => {
      let animation = Animation {
        progress: eased_progress,
        current_time: timeline_time,
        delta_time,
      }
      callback(animation)
    }
    None => ()
  }
}

// Evaluate callback
fn evaluate_callback(item : CallbackItem, timeline_time : Int) -> Unit {
  if not(item.executed) && timeline_time >= item.start_time {
    item.callback()
    item.executed = true
  }
}

// Create a new timeline with default options
pub fn create_timeline() -> Timeline {
  Timeline::new({
    duration: 1000,
    loop: false,
    autoplay: true,
    on_complete: None,
    on_pause: None,
  })
}
