// Animation showcase demo for OpenTUI

fn main {
  // This is a conceptual demo showing how animations would integrate
  // with the component system
  
  println("OpenTUI Animation Showcase")
  println("=========================")
  
  // Create animation manager
  let animation_manager = @animation.AnimationManager::new()
  
  // Create animated components
  let box1 = @animation.AnimatedComponent::new(5, 5, 20, 5)
  let box2 = @animation.AnimatedComponent::new(30, 5, 20, 5)
  let box3 = @animation.AnimatedComponent::new(55, 5, 20, 5)
  
  // Register components
  animation_manager.register(box1)
  animation_manager.register(box2)
  animation_manager.register(box3)
  
  // Demo 1: Slide in animation
  println("\nDemo 1: Slide In Animation")
  box1.slide_in_from_left(1000)
  box2.bounce_in(1200)
  box3.slide_in_from_right(80, 1000)
  
  // Simulate animation frames
  println("Animating slide in...")
  for i = 0; i <= 20; i = i + 1 {
    animation_manager.update(i * 50)
    println("Frame " + i.to_string() + ": Box1 x=" + box1.base.bounds.x.to_string() + 
            ", Box2 opacity=" + box2.opacity.to_string())
  }
  
  // Demo 2: Coordinated fade sequence
  println("\n\nDemo 2: Fade In Sequence")
  let fade_components = [@animation.AnimatedComponent::new(10, 15, 15, 3),
                         @animation.AnimatedComponent::new(30, 15, 15, 3),
                         @animation.AnimatedComponent::new(50, 15, 15, 3)]
  
  let fade_timeline = @animation.create_fade_in_sequence(fade_components, 200)
  fade_timeline.play()
  
  println("Animating fade sequence...")
  for i = 0; i <= 15; i = i + 1 {
    fade_timeline.update(100)
    let opacities = fade_components.map(fn(c) { 
      (c.opacity * 100.0).to_int().to_string() + "%"
    })
    println("Frame " + i.to_string() + ": Opacities = [" + 
            opacities.join(", ") + "]")
  }
  
  // Demo 3: Complex timeline animation
  println("\n\nDemo 3: Complex Timeline")
  let timeline = @animation.create_timeline()
  let animated_box = @animation.AnimatedComponent::new(10, 20, 30, 8)
  
  // Chain multiple animations
  timeline
    .add_animation(0, {
      duration: 1000,
      ease: @animation.OutCirc,
      on_update: Some(fn(anim) {
        animated_box.base.bounds.x = (10.0 + anim.progress * 40.0).to_int()
      }),
      on_complete: Some(fn() { println("Move right complete") }),
      on_start: Some(fn() { println("Starting move right") }),
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
    .call(fn() { println("Halfway point!") }, 500)
    .add_animation(1000, {
      duration: 800,
      ease: @animation.InOutBack,
      on_update: Some(fn(anim) {
        let scale = 1.0 + anim.progress * 0.5
        animated_box.base.bounds.width = (30.0 * scale).to_int()
        animated_box.base.bounds.height = (8.0 * scale).to_int()
      }),
      on_complete: Some(fn() { println("Scale complete") }),
      on_start: None,
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
    .add_animation(1800, {
      duration: 600,
      ease: @animation.InQuad,
      on_update: Some(fn(anim) {
        animated_box.opacity = 1.0 - anim.progress
      }),
      on_complete: Some(fn() { println("Fade out complete") }),
      on_start: None,
      on_loop: None,
      loop: @animation.NoLoop,
      loop_delay: 0,
      alternate: false,
      once: false,
    })
  
  timeline.play()
  
  println("\nRunning complex timeline...")
  for i = 0; i <= 24; i = i + 1 {
    timeline.update(100)
    println("Time: " + (i * 100).to_string() + "ms - " +
            "X: " + animated_box.base.bounds.x.to_string() + ", " +
            "Width: " + animated_box.base.bounds.width.to_string() + ", " +
            "Opacity: " + (animated_box.opacity * 100.0).to_int().to_string() + "%")
  }
  
  // Demo 4: Looping animation
  println("\n\nDemo 4: Looping Wave Animation")
  let wave_components = []
  for i = 0; i < 5; i = i + 1 {
    wave_components.push(@animation.AnimatedComponent::new(10 + i * 15, 30, 10, 3))
  }
  
  let wave_timeline = @animation.create_wave_animation(wave_components, 5, 2000)
  wave_timeline.play()
  
  println("Running wave animation (first 10 frames)...")
  for frame = 0; frame < 10; frame = frame + 1 {
    wave_timeline.update(100)
    let positions = wave_components.map(fn(c) { c.base.bounds.y.to_string() })
    println("Frame " + frame.to_string() + ": Y positions = [" + 
            positions.join(", ") + "]")
  }
  
  println("\n\nAnimation showcase complete!")
  println("\nKey Features Demonstrated:")
  println("- Property animation with easing")
  println("- Timeline-based sequencing")
  println("- Callbacks and events")
  println("- Looping animations")
  println("- Coordinated multi-component animations")
  println("- Preset animation patterns")
}

// Helper extension for arrays (simulation)
fn join[T](arr : Array[T], separator : String) -> String {
  let mut result = ""
  for i = 0; i < arr.length(); i = i + 1 {
    if i > 0 {
      result = result + separator
    }
    result = result + arr[i].to_string()
  }
  result
}

fn map[T, U](arr : Array[T], f : (T) -> U) -> Array[U] {
  let result = []
  for item in arr {
    result.push(f(item))
  }
  result
}
