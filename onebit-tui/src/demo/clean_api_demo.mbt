///| Demo of the clean, declarative API with Yoga layout
///| This is the API we want - minimal, intuitive, flexbox-based


fn main() -> Unit {
  let counter = Ref::new(0)
  let selected = Ref::new(0)
  
  App::new()
    .title("Clean Declarative API Demo")
    .size(100, 30)
    .on_build(fn(_app) {
      // This is the clean API we want!
      Some(
        @ui_builder.vstack()
          .padding(1.0)
          .gap(1.0)
          .children([
            // Header - fixed height
            @ui_builder.box()
              .height(5.0)
              .border(true)
              .title("Clean API Demo")
              .align_items(@types.Align::Center)
              .justify_content(@types.Justify::Center)
              .child(
                @ui_builder.text("Declarative UI with Flexbox")
                  .bold()
                  .color(RGBA::yellow())
                  .build()
              )
              .build(),
            
            // Main content - flex grow
            @ui_builder.hstack()
              .flex_grow(1.0)
              .gap(2.0)
              .children([
                // Sidebar - 30% width
                @ui_builder.box()
                  .flex(0.3)
                  .border(true)
                  .title("Sidebar")
                  .padding(1.0)
                  .child(
                    @ui_builder.vstack()
                      .gap(1.0)
                      .children([
                        @ui_builder.text("Dashboard").build(),
                        @ui_builder.text("Projects").build(),
                        @ui_builder.text("Settings").build(),
                        @ui_builder.spacer(),
                        @ui_builder.text("Counter: \{counter.val}")
                          .color(RGBA::cyan())
                          .build()
                      ])
                      .build()
                  )
                  .build(),
                
                // Content - takes remaining space
                @ui_builder.box()
                  .flex_grow(1.0)
                  .border(true)
                  .title("Content")
                  .padding(2.0)
                  .child(
                    @ui_builder.center()
                      .flex_grow(1.0)
                      .child(
                        @ui_builder.text("Selected: \{selected.val}")
                          .color(RGBA::green())
                          .build()
                      )
                      .build()
                  )
                  .build()
              ])
              .build(),
            
            // Footer - fixed height
            @ui_builder.box()
              .height(3.0)
              .border(true)
              .child(
                @ui_builder.hstack()
                  .padding(0.5)
                  .children([
                    @ui_builder.text("Status: Ready").build(),
                    @ui_builder.spacer(),
                    @ui_builder.text("Q to quit | ↑↓ to select")
                      .color(RGBA::gray())
                      .build()
                  ])
                  .build()
              )
              .build()
          ])
          .build()
      )
    })
    .on_key(Key::ArrowUp, fn() {
      if selected.val > 0 {
        selected.val = selected.val - 1
      }
    })
    .on_key(Key::ArrowDown, fn() {
      selected.val = selected.val + 1
    })
    .on_key(Key::Space, fn() {
      counter.val = counter.val + 1
    })
    .run()
}

///| This is exactly the API we want:
///| 
///| 1. Clean builder pattern: box().flex_grow(1.0).border(true)
///| 2. Flexbox properties directly on components
///| 3. No manual positioning or sizing (except fixed heights)
///| 4. Familiar patterns: hstack(), vstack(), spacer()
///| 5. Yoga does all the layout math
///| 
///| Compare to the verbose old way:
///| - No set_bounds(x, y, width, height)
///| - No manual position calculations
///| - No buffer.write_string() with coordinates
///| - Just declare the UI structure!