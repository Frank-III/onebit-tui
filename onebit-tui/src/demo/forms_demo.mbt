///| Demo showcasing form components: checkbox, radio, select, toggle

fn forms_demo_main() -> Unit {
  println("=== OneBit-TUI Forms Demo ===")
  match @core.App::init() {
    None => println("Failed to initialize renderer")
    Some(app) => {
      // Form state
      let agree_terms : Ref[Bool] = Ref::new(false)
      let newsletter : Ref[Bool] = Ref::new(true)
      let dark_mode : Ref[Bool] = Ref::new(true)
      
      let gender : Ref[String] = Ref::new("other")
      let country : Ref[String] = Ref::new("us")
      let languages : Ref[Array[String]] = Ref::new(["en"])
      
      let result : Ref[String] = Ref::new("Form not submitted yet")
      
      // Build UI
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
              @components.View::text("Form Components Demo", Some(@core.Color::BrightWhite))
            ]),
          
          // Two column layout
          @components.View::new()
            .row()
            .flex(1.0)
            .gap(2.0)
            .children([
              // Left column - Checkboxes and Toggles
              @components.View::new()
                .column()
                .flex(1.0)
                .padding(1.0)
                .gap(1.0)
                .border(@components.BorderStyle::Single, @core.Color::Gray)
                .children([
                  @components.View::text("Settings", Some(@core.Color::Yellow)),
                  @components.checkbox("I agree to terms", agree_terms),
                  @components.checkbox("Subscribe to newsletter", newsletter),
                  @components.toggle("Dark mode", dark_mode),
                  
                  // Multi-checkbox group
                  @components.View::text("Languages:", Some(@core.Color::Yellow)),
                  @components.checkbox_group(
                    [
                      @components.CheckboxOption::{ value: "en", label: "English" },
                      @components.CheckboxOption::{ value: "es", label: "Spanish" },
                      @components.CheckboxOption::{ value: "fr", label: "French" },
                      @components.CheckboxOption::{ value: "de", label: "German" }
                    ],
                    languages
                  )
                ]),
              
              // Right column - Radio and Select
              @components.View::new()
                .column()
                .flex(1.0)
                .padding(1.0)
                .gap(1.0)
                .border(@components.BorderStyle::Single, @core.Color::Gray)
                .children([
                  @components.View::text("Selection", Some(@core.Color::Yellow)),
                  
                  // Radio group
                  @components.View::text("Gender:", Some(@core.Color::White)),
                  @components.radio_group(
                    [
                      @components.RadioOption::{ value: "male", label: "Male" },
                      @components.RadioOption::{ value: "female", label: "Female" },
                      @components.RadioOption::{ value: "other", label: "Other" }
                    ],
                    gender
                  ),
                  
                  // Dropdown select
                  @components.View::text("Country:", Some(@core.Color::White)),
                  @components.select(
                    [
                      @components.SelectOption::{ value: "us", label: "United States", disabled: None },
                      @components.SelectOption::{ value: "uk", label: "United Kingdom", disabled: None },
                      @components.SelectOption::{ value: "ca", label: "Canada", disabled: None },
                      @components.SelectOption::{ value: "au", label: "Australia", disabled: None },
                      @components.SelectOption::{ value: "other", label: "Other", disabled: None }
                    ],
                    country,
                    placeholder="Select country..."
                  )
                ])
            ]),
          
          // Submit button and result
          @components.View::new()
            .row()
            .gap(2.0)
            .children([
              @components.make_button("Submit", true, fn() {
                if agree_terms.val {
                  let langs = languages.val.length().to_string() + " language(s)"
                  result.val = "Submitted! Newsletter: " + newsletter.val.to_string() + 
                               ", Gender: " + gender.val + ", Country: " + country.val +
                               ", Languages: " + langs
                } else {
                  result.val = "Please agree to terms first!"
                }
              }),
              @components.make_button("Reset", false, fn() {
                agree_terms.val = false
                newsletter.val = true
                dark_mode.val = true
                gender.val = "other"
                country.val = "us"
                languages.val = ["en"]
                result.val = "Form reset"
              })
            ]),
          
          // Result display
          @components.View::new()
            .padding(1.0)
            .border(@components.BorderStyle::Single, @core.Color::Gray)
            .children([
              @components.View::new().text_bind(fn() { result.val }, color=@core.Color::BrightGreen)
            ]),
          
          // Footer
          @components.View::new()
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Use Tab to navigate, Space/Enter to select, 'q' to quit", Some(@core.Color::BrightWhite))
            ])
        ])
      
      // Run event loop
      @components.run_event_loop(app, ui, fps=30)
      app.cleanup()
    }
  }
}