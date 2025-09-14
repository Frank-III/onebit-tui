///| Demo showing all the common UI patterns with the clean API


fn main() -> Unit {
  let selected_tab = Ref::new(0)
  
  App::new()
    .title("Common UI Patterns")
    .size(120, 35)
    .on_build(fn(_app) {
      Some(
        @ui_builder.vstack()
          .padding(1.0)
          .children([
            // Pattern 1: Header + Content + Footer
            header_content_footer_pattern(),
            
            // Pattern 2: Sidebar + Content (30/70 split)
            @ui_builder.hstack()
              .flex_grow(1.0)
              .gap(1.0)
              .children([
                sidebar_pattern(),
                content_pattern()
              ])
              .build(),
            
            // Pattern 3: Spacer for alignment
            spacer_pattern()
          ])
          .build()
      )
    })
    .on_key(Key::Tab, fn() {
      selected_tab.val = (selected_tab.val + 1) % 3
    })
    .run()
}

// Pattern 1: Header + Content + Footer
fn header_content_footer_pattern() -> @ui_builder.UIBuilder {
  @ui_builder.box()
    .height(5.0)  // Fixed height header
    .border(true)
    .title("Header (fixed height)")
    .align_items(@types.Align::Center)
    .justify_content(@types.Justify::Center)
    .child(
      @ui_builder.text("Common UI Patterns Demo")
        .bold()
        .color(RGBA::cyan())
        .build()
    )
    .build()
}

// Pattern 2a: Sidebar (30% width)
fn sidebar_pattern() -> @ui_builder.UIBuilder {
  @ui_builder.box()
    .flex(0.3)  // 30% of available width
    .border(true)
    .title("Sidebar (30%)")
    .padding(1.0)
    .child(
      @ui_builder.list([
        "Dashboard",
        "Analytics", 
        "Reports",
        "Settings",
        "Help"
      ])
        .flex_grow(1.0)
        .build()
    )
    .build()
}

// Pattern 2b: Content area (70% width)
fn content_pattern() -> @ui_builder.UIBuilder {
  @ui_builder.box()
    .flex_grow(1.0)  // Takes remaining space
    .border(true)
    .title("Content (flex-grow)")
    .padding(2.0)
    .child(
      @ui_builder.vstack()
        .gap(1.0)
        .children([
          // Select component with flex
          @ui_builder.select([
            "Option 1 - Uses flex_grow",
            "Option 2 - Fills available space",
            "Option 3 - No manual sizing"
          ])
            .flex_grow(1.0)  // Fills available height
            .border(true)
            .build(),
          
          // Buttons row
          button_row_pattern()
        ])
        .build()
    )
    .build()
}

// Pattern 3: Spacer pushes content apart
fn spacer_pattern() -> @ui_builder.UIBuilder {
  @ui_builder.box()
    .height(3.0)  // Fixed footer height
    .border(true)
    .padding(0.5)
    .child(
      @ui_builder.hstack()
        .children([
          @ui_builder.text("Left aligned").build(),
          @ui_builder.spacer(),  // Pushes content to edges
          @ui_builder.text("Center")
            .color(RGBA::yellow())
            .build(),
          @ui_builder.spacer(),  // Another spacer
          @ui_builder.text("Right aligned").build()
        ])
        .build()
    )
    .build()
}

// Pattern 4: Button row with equal spacing
fn button_row_pattern() -> @ui_builder.UIBuilder {
  @ui_builder.hstack()
    .height(3.0)
    .gap(1.0)
    .children([
      // Each button takes equal space
      @ui_builder.center()
        .flex(1.0)
        .border(true)
        .child(@ui_builder.text("OK").bold().build())
        .build(),
      
      @ui_builder.center()
        .flex(1.0)
        .border(true)
        .child(@ui_builder.text("Cancel").build())
        .build(),
      
      @ui_builder.center()
        .flex(1.0)
        .border(true)
        .child(@ui_builder.text("Apply").build())
        .build()
    ])
    .build()
}

///| Key Patterns Demonstrated:
///| 
///| 1. **Fixed + Flexible**: 
///|    - Headers/footers use height(5.0)
///|    - Content uses flex_grow(1.0)
///| 
///| 2. **Proportional Split**:
///|    - Sidebar uses flex(0.3) for 30%
///|    - Content uses flex_grow(1.0) for remaining 70%
///| 
///| 3. **Spacers**:
///|    - spacer() has flex_grow(1.0) by default
///|    - Pushes surrounding content to edges
///| 
///| 4. **Equal Distribution**:
///|    - Multiple items with flex(1.0) share space equally
///| 
///| 5. **Centering**:
///|    - center() sets both align_items and justify_content
///| 
///| No manual calculations needed - Yoga handles everything!