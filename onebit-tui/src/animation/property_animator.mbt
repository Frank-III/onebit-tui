// Property animator for animating numeric properties on components

pub struct PropertyAnimator {
  target : Ref[Any]
  property_name : String
  from_value : Double
  to_value : Double
  duration : Int  // milliseconds
  elapsed : Int
  easing : EasingFunction
  on_update : Option[(Double) -> Unit]
  on_complete : Option[() -> Unit]
  is_complete : Bool
}

pub fn PropertyAnimator::new(
  target : Ref[Any],
  property_name : String,
  from : Double,
  to : Double,
  duration : Int,
  easing : EasingFunction
) -> PropertyAnimator {
  {
    target,
    property_name,
    from_value: from,
    to_value: to,
    duration,
    elapsed: 0,
    easing,
    on_update: None,
    on_complete: None,
    is_complete: false,
  }
}

pub fn set_on_update(self : PropertyAnimator, callback : (Double) -> Unit) -> PropertyAnimator {
  self.on_update = Some(callback)
  self
}

pub fn set_on_complete(self : PropertyAnimator, callback : () -> Unit) -> PropertyAnimator {
  self.on_complete = Some(callback)
  self
}

pub fn update(self : PropertyAnimator, delta_time : Int) -> Unit {
  if self.is_complete {
    return
  }
  
  self.elapsed = self.elapsed + delta_time
  
  if self.elapsed >= self.duration {
    self.elapsed = self.duration
    self.is_complete = true
  }
  
  let progress = self.elapsed.to_double() / self.duration.to_double()
  let eased_progress = apply_easing(self.easing, progress)
  let current_value = self.from_value + (self.to_value - self.from_value) * eased_progress
  
  match self.on_update {
    Some(callback) => callback(current_value)
    None => ()
  }
  
  if self.is_complete {
    match self.on_complete {
      Some(callback) => callback()
      None => ()
    }
  }
}

pub fn reset(self : PropertyAnimator) -> Unit {
  self.elapsed = 0
  self.is_complete = false
}

pub fn is_complete(self : PropertyAnimator) -> Bool {
  self.is_complete
}

// Animate a component property
pub fn animate_property(
  target : Ref[Any],
  property_name : String,
  from : Double,
  to : Double,
  duration : Int,
  easing : EasingFunction,
  on_update : (Double) -> Unit,
  on_complete : Option[() -> Unit]
) -> PropertyAnimator {
  let animator = PropertyAnimator::new(target, property_name, from, to, duration, easing)
  animator.on_update = Some(on_update)
  animator.on_complete = on_complete
  animator
}

// Common animation presets
pub fn fade_in(target : Ref[Any], duration : Int) -> PropertyAnimator {
  animate_property(
    target,
    "opacity",
    0.0,
    1.0,
    duration,
    OutQuad,
    fn(value) { 
      // Update opacity on target
    },
    None
  )
}

pub fn fade_out(target : Ref[Any], duration : Int) -> PropertyAnimator {
  animate_property(
    target,
    "opacity",
    1.0,
    0.0,
    duration,
    InQuad,
    fn(value) {
      // Update opacity on target
    },
    None
  )
}

pub fn slide_in(target : Ref[Any], from_x : Int, to_x : Int, duration : Int) -> PropertyAnimator {
  animate_property(
    target,
    "x",
    from_x.to_double(),
    to_x.to_double(),
    duration,
    OutBack,
    fn(value) {
      // Update x position on target
    },
    None
  )
}

pub fn bounce(target : Ref[Any], height : Int, duration : Int) -> PropertyAnimator {
  animate_property(
    target,
    "y",
    0.0,
    height.to_double(),
    duration,
    OutBounce,
    fn(value) {
      // Update y position on target
    },
    None
  )
}
