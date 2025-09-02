// Animated component wrapper for OpenTUI

pub struct AnimatedComponent {
  base : @core.BaseRenderable
  mut x_animator : Option[PropertyAnimator]
  mut y_animator : Option[PropertyAnimator]
  mut opacity_animator : Option[PropertyAnimator]
  mut opacity : Double
}

pub fn AnimatedComponent::new(x : Int, y : Int, width : Int, height : Int) -> AnimatedComponent {
  let component = {
    base: @core.BaseRenderable::new(x, y, width, height),
    x_animator: None,
    y_animator: None,
    opacity_animator: None,
    opacity: 1.0,
  }
  
  // Set up render function
  component.base.set_render_fn(fn(_base, buffer) { component.render(buffer) })
  component
}

pub fn as_renderable(self : AnimatedComponent) -> @core.BaseRenderable {
  self.base
}

// Animation methods
pub fn animate_to(self : AnimatedComponent, x : Int, y : Int, duration : Int, easing : EasingFunction) -> Unit {
  let current_x = self.base.bounds.x.to_double()
  let current_y = self.base.bounds.y.to_double()
  
  // Create X animator
  let x_ref = Ref::new(self)
  self.x_animator = Some(PropertyAnimator::new(
    x_ref,
    "x",
    current_x,
    x.to_double(),
    duration,
    easing
  ).set_on_update(fn(value) {
    self.base.bounds.x = value.to_int()
  }))
  
  // Create Y animator
  let y_ref = Ref::new(self)
  self.y_animator = Some(PropertyAnimator::new(
    y_ref,
    "y", 
    current_y,
    y.to_double(),
    duration,
    easing
  ).set_on_update(fn(value) {
    self.base.bounds.y = value.to_int()
  }))
}

pub fn fade_to(self : AnimatedComponent, opacity : Double, duration : Int, easing : EasingFunction) -> Unit {
  let opacity_ref = Ref::new(self)
  self.opacity_animator = Some(PropertyAnimator::new(
    opacity_ref,
    "opacity",
    self.opacity,
    opacity,
    duration,
    easing
  ).set_on_update(fn(value) {
    self.opacity = value
  }))
}

pub fn slide_in_from_left(self : AnimatedComponent, duration : Int) -> Unit {
  let target_x = self.base.bounds.x
  self.base.bounds.x = -self.base.bounds.width
  self.animate_to(target_x, self.base.bounds.y, duration, OutBack)
}

pub fn slide_in_from_right(self : AnimatedComponent, screen_width : Int, duration : Int) -> Unit {
  let target_x = self.base.bounds.x
  self.base.bounds.x = screen_width
  self.animate_to(target_x, self.base.bounds.y, duration, OutBack)
}

pub fn bounce_in(self : AnimatedComponent, duration : Int) -> Unit {
  self.opacity = 0.0
  self.fade_to(1.0, duration / 2, OutQuad)
  
  let target_y = self.base.bounds.y
  self.base.bounds.y = target_y - 20
  self.animate_to(self.base.bounds.x, target_y, duration, OutBounce)
}

// Update animations
pub fn update_animations(self : AnimatedComponent, delta_time : Int) -> Unit {
  match self.x_animator {
    Some(animator) => {
      if not(animator.is_complete()) {
        animator.update(delta_time)
      }
    }
    None => ()
  }
  
  match self.y_animator {
    Some(animator) => {
      if not(animator.is_complete()) {
        animator.update(delta_time)
      }
    }
    None => ()
  }
  
  match self.opacity_animator {
    Some(animator) => {
      if not(animator.is_complete()) {
        animator.update(delta_time)
      }
    }
    None => ()
  }
}

// Render with opacity
fn render(self : AnimatedComponent, buffer : @core.Buffer) -> Unit {
  if not(self.base.visible) || self.opacity <= 0.0 {
    return
  }
  
  // Note: In a real implementation, we'd apply opacity to the rendering
  // For now, we'll just skip rendering if opacity is too low
  if self.opacity < 0.1 {
    return
  }
  
  // Render children or content here
  // This is a placeholder - actual rendering would depend on the component type
  let bounds = self.base.bounds
  for y = bounds.y; y < bounds.y + bounds.height; y = y + 1 {
    for x = bounds.x; x < bounds.x + bounds.width; x = x + 1 {
      if x >= 0 && x < buffer.width && y >= 0 && y < buffer.height {
        // Apply a simple opacity effect by modifying the style
        let alpha = (self.opacity * 255.0).to_int()
        if alpha > 128 {  // Only render if opacity is high enough
          buffer.write_char(x, y, ' ', @core.Style::new(bg=@core.Color::rgb(50, 50, 100)))
        }
      }
    }
  }
}

// Animation manager for coordinating multiple animations
pub struct AnimationManager {
  mut components : Array[AnimatedComponent]
  mut timeline : Timeline
  mut last_update : Int
}

pub fn AnimationManager::new() -> AnimationManager {
  {
    components: [],
    timeline: create_timeline(),
    last_update: 0,
  }
}

pub fn register(self : AnimationManager, component : AnimatedComponent) -> Unit {
  self.components.push(component)
}

pub fn update(self : AnimationManager, current_time : Int) -> Unit {
  let delta = if self.last_update == 0 { 0 } else { current_time - self.last_update }
  self.last_update = current_time
  
  // Update timeline
  self.timeline.update(delta)
  
  // Update all components
  for component in self.components {
    component.update_animations(delta)
  }
}

// Preset animations
pub fn create_fade_in_sequence(components : Array[AnimatedComponent], delay : Int) -> Timeline {
  let timeline = create_timeline()
  
  for i = 0; i < components.length(); i = i + 1 {
    let component = components[i]
    let start_time = i * delay
    
    timeline.add_animation(start_time, {
      duration: 500,
      ease: OutQuad,
      on_start: Some(fn() {
        component.opacity = 0.0
      }),
      on_update: Some(fn(anim) {
        component.opacity = anim.progress
      }),
      on_complete: None,
      on_loop: None,
      loop: NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
  }
  
  timeline
}

pub fn create_wave_animation(components : Array[AnimatedComponent], amplitude : Int, duration : Int) -> Timeline {
  let timeline = create_timeline()
  
  for i = 0; i < components.length(); i = i + 1 {
    let component = components[i]
    let phase = i.to_double() * 0.2
    let original_y = component.base.bounds.y
    
    timeline.add_animation(0, {
      duration,
      ease: InOutSine,
      on_update: Some(fn(anim) {
        let offset = @math.sin(anim.progress * @math.pi * 2.0 + phase) * amplitude.to_double()
        component.base.bounds.y = original_y + offset.to_int()
      }),
      on_complete: None,
      on_start: None,
      on_loop: None,
      loop: Infinite,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
  }
  
  timeline
}
