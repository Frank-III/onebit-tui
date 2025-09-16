///| Demo showcasing table component

fn table_demo_main() -> Unit {
  println("=== OneBit-TUI Table Demo ===")
  match @core.App::init() {
    None => println("Failed to initialize renderer")
    Some(app) => {
      // State for selected rows
      let selected_user : Ref[Int] = Ref::new(0)
      let selected_product : Ref[Int] = Ref::new(-1)
      let action_result : Ref[String] = Ref::new("Select a row to see details")
      
      // Sample data
      let user_columns = [
        @components.Column::{ key: "id", title: "ID", width: Some(5), flex: None, align: Some(@components.ColumnAlign::Right) },
        @components.Column::{ key: "name", title: "Name", width: None, flex: Some(2.0), align: Some(@components.ColumnAlign::Left) },
        @components.Column::{ key: "email", title: "Email", width: None, flex: Some(3.0), align: Some(@components.ColumnAlign::Left) },
        @components.Column::{ key: "role", title: "Role", width: Some(10), flex: None, align: Some(@components.ColumnAlign::Center) },
        @components.Column::{ key: "status", title: "Status", width: Some(8), flex: None, align: Some(@components.ColumnAlign::Center) }
      ]
      
      let user_rows = [
        @components.TableRow::{ cells: ["1", "Alice Smith", "alice@example.com", "Admin", "Active"], selectable: None },
        @components.TableRow::{ cells: ["2", "Bob Johnson", "bob@example.com", "User", "Active"], selectable: None },
        @components.TableRow::{ cells: ["3", "Charlie Brown", "charlie@example.com", "Moderator", "Inactive"], selectable: Some(false) },  // Not selectable
        @components.TableRow::{ cells: ["4", "Diana Prince", "diana@example.com", "Admin", "Active"], selectable: None },
        @components.TableRow::{ cells: ["5", "Eve Wilson", "eve@example.com", "User", "Pending"], selectable: None }
      ]
      
      let product_columns = [
        @components.Column::{ key: "name", title: "Product", width: None, flex: Some(2.0), align: None },
        @components.Column::{ key: "price", title: "Price", width: Some(10), flex: None, align: Some(@components.ColumnAlign::Right) },
        @components.Column::{ key: "stock", title: "Stock", width: Some(8), flex: None, align: Some(@components.ColumnAlign::Right) }
      ]
      
      let product_rows = [
        @components.TableRow::{ cells: ["Laptop Pro", "$1,299.99", "15"], selectable: None },
        @components.TableRow::{ cells: ["Wireless Mouse", "$29.99", "142"], selectable: None },
        @components.TableRow::{ cells: ["USB-C Cable", "$19.99", "0"], selectable: None },
        @components.TableRow::{ cells: ["Mechanical Keyboard", "$149.99", "38"], selectable: None }
      ]
      
      // Build UI
      let ui = @components.View::new()
        .column()
        .padding(2.0)
        .gap(1.0)
        .background(@core.Color::Black)
        .children([
          // Header
          @components.View::new()
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Table Component Demo", Some(@core.Color::BrightWhite))
            ]),
          
          // Two tables side by side
          @components.View::new()
            .row()
            .flex(1.0)
            .gap(2.0)
            .children([
              // Users table
              @components.View::new()
                .column()
                .flex(3.0)
                .gap(1.0)
                .children([
                  @components.View::text("Users (with selection)", Some(@core.Color::Yellow)),
                  @components.table(
                    user_columns,
                    user_rows,
                    selected_row=selected_user,
                    on_select=fn(index) {
                      if index >= 0 && index < user_rows.length() {
                        let row = user_rows[index]
                        action_result.val = "Selected user: " + row.cells[1] + " (" + row.cells[2] + ")"
                      }
                    },
                    max_height=10
                  )
                ]),
              
              // Products table
              @components.View::new()
                .column()
                .flex(2.0)
                .gap(1.0)
                .children([
                  @components.View::text("Products (simple)", Some(@core.Color::Yellow)),
                  @components.simple_table(
                    ["Product", "Price", "Stock"],
                    [
                      ["Laptop Pro", "$1,299.99", "15"],
                      ["Wireless Mouse", "$29.99", "142"],
                      ["USB-C Cable", "$19.99", "0"],
                      ["Mechanical Keyboard", "$149.99", "38"]
                    ]
                  )
                ])
            ]),
          
          // Simple stats table
          @components.View::new()
            .column()
            .gap(1.0)
            .children([
              @components.View::text("Statistics", Some(@core.Color::Yellow)),
              @components.simple_table(
                ["Metric", "Today", "This Week", "This Month"],
                [
                  ["New Users", "12", "84", "342"],
                  ["Orders", "45", "312", "1,428"],
                  ["Revenue", "$2,341", "$18,923", "$72,451"],
                  ["Tickets", "8", "52", "189"]
                ],
                border_style=@components.BorderStyle::Double
              )
            ]),
          
          // Status bar
          @components.View::new()
            .padding(1.0)
            .border(@components.BorderStyle::Single, @core.Color::Gray)
            .children([
              @components.View::new().text_bind(fn() { action_result.val }, color=@core.Color::BrightGreen)
            ]),
          
          // Footer
          @components.View::new()
            .padding(1.0)
            .background(@core.Color::Blue)
            .children([
              @components.View::text("Use arrows to navigate tables, Enter to select, 'q' to quit", Some(@core.Color::BrightWhite))
            ])
        ])
      
      // Run event loop
      @components.run_event_loop(app, ui, fps=30)
      app.cleanup()
    }
  }
}