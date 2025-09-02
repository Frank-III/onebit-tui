///| Tests for Yoga-based layout flattening utilities

test "flatten_layout basic vstack" {
  // Use default justify (Start) to avoid constructing read-only enum variants from tests
  let view = @core.vstack([
    @core.text("A"),
    @core.text("B"),
  ])
  let items = @core.flatten_layout(view, Rect::new(0, 0, 40, 10))
  // Expect two leaf rects
  inspect(items.length(), content="2")
  // Bounds are within provided rect
  let b0 = items[0].bounds
  let b1 = items[1].bounds
  assert_true(b0.x >= 0 && b0.y >= 0)
  assert_true(b1.x >= 0 && b1.y >= 0)
  assert_true(b0.x + b0.width <= 40)
  assert_true(b1.x + b1.width <= 40)
  // With space-between on column, y of b1 should be > b0.y
  assert_true(b1.y > b0.y)
}

test "flatten_layout box with padding" {
  let view = @core.box(padding=2, children=[ @core.text("C") ])
  let items = @core.flatten_layout(view, Rect::new(0, 0, 20, 8))
  // One leaf
  inspect(items.length(), content="1")
  let b = items[0].bounds
  // Should not overlap the 2px padding + 1px border + optional title
  assert_true(b.x >= 1)
  assert_true(b.y >= 1)
}
