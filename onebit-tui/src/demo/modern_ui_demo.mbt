///| Modern declarative UI demo - like React/Solid but in MoonBit!
///| Components use flexbox properties directly, no manual sizing


fn main() -> Unit {
  let selected_tab = Ref::new(0)
  let input_value = Ref::new("")
  let counter = Ref::new(0)
  
  App::new()
    .title("Modern Declarative UI")
    .with_yoga(true)
    .on_layout(fn(_app, root) {
      // The UI tree - just like React/Solid!
      let ui = 
        @ui.vstack()
          .padding(1.0)
          .gap(1.0)
          .children([
            // Header - fixed height
            @ui.box()
              .height(5.0)
              .border(true)
              .title("OpenTUI Modern API")
              .align_items(@types.Align::Center)
              .justify_content(@types.Justify::Center)
              .child(
                @ui.text("Declarative UI with Flexbox")
                  .bold()
                  .color(RGBA::yellow())
                  .build()
              )
              .build(),
            
            // Main content - flex grow
            @ui.hstack()
              .flex_grow(1.0)
              .gap(2.0)
              .children([
                // Sidebar - 30% width using flex
                @ui.vstack()
                  .flex(0.3)  // 30% of available space
                  .border(true)
                  .title("Menu")
                  .padding(1.0)
                  .children([
                    @ui.text("Dashboard").build(),
                    @ui.text("Projects").build(),
                    @ui.text("Settings").build(),
                    @ui.spacer(),  // Push next item to bottom
                    @ui.text("Help").color(RGBA::gray()).build()
                  ])
                  .build(),
                
                // Content area - flex grow to fill remaining
                @ui.box()
                  .flex_grow(1.0)
                  .border(true)
                  .title("Content")
                  .padding(2.0)
                  .flex_direction(@types.FlexDirection::Column)
                  .gap(1.0)
                  .children([
                    // Input field
                    @ui.box()
                      .height(3.0)
                      .border(true)
                      .child(
                        @ui.input()
                          .placeholder("Enter your name...")
                          .focused(true)
                          .on_input(fn(value) { input_value.val = value })
                          .build()
                      )
                      .build(),
                    
                    // Select component - no manual height!
                    @ui.select(["Option 1", "Option 2", "Option 3"])
                      .flex_grow(1.0)  // Takes remaining space
                      .on_select(fn(idx) { selected_tab.val = idx })
                      .build(),
                    
                    // Bottom buttons
                    @ui.hstack()
                      .height(3.0)
                      .gap(1.0)
                      .children([
                        @ui.box()
                          .flex(1.0)
                          .border(true)
                          .align_items(@types.Align::Center)
                          .justify_content(@types.Justify::Center)
                          .child(@ui.text("OK").build())
                          .build(),
                        @ui.box()
                          .flex(1.0)
                          .border(true)
                          .align_items(@types.Align::Center)
                          .justify_content(@types.Justify::Center)
                          .child(@ui.text("Cancel").build())
                          .build()
                      ])
                      .build()
                  ])
                  .build()
              ])
              .build(),
            
            // Footer - fixed height
            @ui.center()
              .height(3.0)
              .border(true)
              .child(
                @ui.text("Press Q to quit | Tab: \{selected_tab.val} | Input: \{input_value.val}")
                  .color(RGBA::cyan())
                  .build()
              )
              .build()
          ])
          .build()
      
      // Connect UI tree to root
      root.add_child(ui.yoga_node)
    })
    .on_update(fn(app, buffer) {
      // The UI tree renders itself based on Yoga layout
      // No manual positioning needed!
      counter.val = counter.val + 1
      
      // In a real implementation, the UI tree would render here
      // For now, show the concept
      buffer.write_string(
        5, 5,
        "Frame: \{counter.val} - UI renders automatically with Yoga layout",
        RGBA::gray(),
        RGBA::transparent(),
        TextStyle::None
      )
    })
    .run()
}

///| This is what the API should feel like:
///| 
///| Compare to Solid.js:
///| ```jsx
///| <Box flexDirection="column" padding={1} gap={1}>
///|   <Box height={5} border title="Header">
///|     <Text bold color="yellow">Title</Text>
///|   </Box>
///|   <Box flexGrow={1} flexDirection="row">
///|     <Box flex={0.3} border>Sidebar</Box>
///|     <Box flexGrow={1} border>Content</Box>
///|   </Box>
///| </Box>
///| ```
///| 
///| In MoonBit:
///| ```moonbit
///| vstack()
///|   .padding(1.0)
///|   .gap(1.0)
///|   .children([
///|     box().height(5.0).border(true).title("Header")
///|       .child(text("Title").bold().color(yellow)),
///|     hstack().flex_grow(1.0).children([
///|       box().flex(0.3).border(true),  // Sidebar
///|       box().flex_grow(1.0).border(true)  // Content
///|     ])
///|   ])
///| ```