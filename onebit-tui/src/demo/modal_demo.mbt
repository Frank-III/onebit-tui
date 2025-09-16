///| Demo showcasing modal dialogs with focus trap

fn modal_demo_main() -> Unit {
  println("=== OneBit-TUI Modal Demo ===")
  match @core.App::init() {
    None => println("Failed to initialize renderer")
    Some(app) => {
      // Modal state
      let show_modal : Ref[Bool] = Ref::new(false)
      let show_confirm : Ref[Bool] = Ref::new(false)
      let modal_result : Ref[String] = Ref::new("No action taken yet")
      
      // Form state for custom modal
      let name : Ref[String] = Ref::new("")
      let name_caret : Ref[Int] = Ref::new(0)
      let email : Ref[String] = Ref::new("")
      let email_caret : Ref[Int] = Ref::new(0)
      
      // Build the main UI
      let ui = @components.View::new()
        .column()
        .padding(2.0)
        .gap(2.0)
        .background(@core.Color::Black)
        .children([
          // Header
          @components.View::new()
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Modal Dialog Demo", Some(@core.Color::BrightWhite))
            ]),
          
          // Instructions
          @components.View::text("Use Tab/Shift+Tab to navigate, Enter/Space to activate buttons", Some(@core.Color::Gray)),
          
          // Button row
          @components.View::new()
            .row()
            .gap(2.0)
            .children([
              @components.make_button("Open Form Modal", true, fn() {
                show_modal.val = true
                // Reset form
                name.val = ""
                name_caret.val = 0
                email.val = ""
                email_caret.val = 0
              }),
              @components.make_button("Open Confirm Dialog", false, fn() {
                show_confirm.val = true
              }),
              @components.make_button("Exit", false, fn() {
                modal_result.val = "Exiting..."
              })
            ]),
          
          // Result display
          @components.View::new()
            .padding(1.0)
            .border(@components.BorderStyle::Single, @core.Color::Gray)
            .children([
              @components.View::text("Result: ", Some(@core.Color::Yellow)),
              @components.View::new().text_bind(fn() { modal_result.val }, color=@core.Color::White)
            ]),
          
          // Custom form modal
          if show_modal.val {
            @components.modal(
              {
                title: "User Information",
                width: Some(@types.Value::percent(50.0)),
                height: Some(@types.Value::point(15.0)),
                show_close: Some(true),
                on_close: Some(fn() { 
                  show_modal.val = false
                  modal_result.val = "Form cancelled"
                })
              },
              @components.View::new()
                .column()
                .gap(1.0)
                .children([
                  @components.View::text("Name:", Some(@core.Color::White)),
                  @components.input_edit(name, caret=name_caret, placeholder="Enter your name"),
                  @components.View::text("Email:", Some(@core.Color::White)),
                  @components.input_edit(email, caret=email_caret, placeholder="Enter your email"),
                  @components.View::new()
                    .row()
                    .justify_content(@types.Justify::Center)
                    .gap(2.0)
                    .margin_top(2.0)
                    .children([
                      @components.make_button("Submit", true, fn() {
                        modal_result.val = "Submitted: " + name.val + " <" + email.val + ">"
                        show_modal.val = false
                      }),
                      @components.make_button("Cancel", false, fn() {
                        show_modal.val = false
                        modal_result.val = "Form cancelled"
                      })
                    ])
                ]),
              show_modal
            )
          } else {
            @components.View::new()
          },
          
          // Confirm dialog
          if show_confirm.val {
            @components.confirm_modal(
              "Confirm Action",
              "Are you sure you want to proceed with this action?",
              fn() {
                modal_result.val = "Action confirmed!"
              },
              Some(fn() {
                modal_result.val = "Action cancelled"
              }),
              show_confirm
            )
          } else {
            @components.View::new()
          }
        ])
      
      // Run event loop
      @components.run_event_loop(app, ui, fps=30)
      app.cleanup()
    }
  }
}