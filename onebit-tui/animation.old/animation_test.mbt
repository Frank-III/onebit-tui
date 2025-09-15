// Tests for animation system

test "easing functions produce correct values" {
  // Linear
  @assertion.assert_eq(apply_easing(Linear, 0.0), 0.0)
  @assertion.assert_eq(apply_easing(Linear, 0.5), 0.5)
  @assertion.assert_eq(apply_easing(Linear, 1.0), 1.0)
  
  // InQuad
  @assertion.assert_eq(apply_easing(InQuad, 0.0), 0.0)
  @assertion.assert_eq(apply_easing(InQuad, 0.5), 0.25)
  @assertion.assert_eq(apply_easing(InQuad, 1.0), 1.0)
  
  // OutQuad  
  @assertion.assert_eq(apply_easing(OutQuad, 0.0), 0.0)
  @assertion.assert_eq(apply_easing(OutQuad, 0.5), 0.75)
  @assertion.assert_eq(apply_easing(OutQuad, 1.0), 1.0)
}

test "property animator interpolates values correctly" {
  let target = Ref::new({ x: 0, y: 0 })
  let mut current_value = 0.0
  
  let animator = PropertyAnimator::new(
    target,
    "x",
    0.0,
    100.0,
    1000,
    Linear
  )
  
  animator.set_on_update(fn(value) { current_value = value })
  
  // Test at different time points
  animator.update(0)
  @assertion.assert_eq(current_value, 0.0)
  
  animator.update(250)
  @assertion.assert_eq(current_value, 25.0)
  
  animator.update(250)
  @assertion.assert_eq(current_value, 50.0)
  
  animator.update(500)
  @assertion.assert_eq(current_value, 100.0)
  
  @assertion.assert_true(animator.is_complete())
}

test "timeline executes callbacks at correct times" {
  let mut callback_executed = false
  let mut callback_time = 0
  
  let timeline = Timeline::new({
    duration: 1000,
    loop: false,
    autoplay: false,
    on_complete: None,
    on_pause: None,
  })
  
  timeline.call(fn() { 
    callback_executed = true
    callback_time = timeline.current_time
  }, 500)
  
  timeline.play()
  
  // Before callback time
  timeline.update(250)
  @assertion.assert_false(callback_executed)
  
  // After callback time
  timeline.update(300)
  @assertion.assert_true(callback_executed)
  @assertion.assert_eq(callback_time, 550)
}

test "timeline loops correctly" {
  let mut loop_count = 0
  
  let timeline = Timeline::new({
    duration: 100,
    loop: true,
    autoplay: false,
    on_complete: None,
    on_pause: None,
  })
  
  timeline.call(fn() { loop_count = loop_count + 1 }, 50)
  timeline.play()
  
  // First loop
  timeline.update(60)
  @assertion.assert_eq(loop_count, 1)
  
  // Complete first loop and start second
  timeline.update(60)
  @assertion.assert_eq(loop_count, 2)
  
  // Third loop
  timeline.update(100)
  @assertion.assert_eq(loop_count, 3)
}
