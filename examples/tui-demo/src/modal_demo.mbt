///|
/// Modal demo – focus trap, Escape close, focus restore
pub fn main_modal_demo() -> Unit {
  match @core.App::init() {
    None => println("Failed to initialize app")
    Some(app) => {
      let status = Ref::new("No action yet".to_string())

      // Predefine stable IDs for focus restore
      let open_confirm_id = 4101
      let open_custom_id = 4102

      // Actions to open modals
      let open_confirm = fn() {
        let dialog = @widget.ConfirmDialog::new("Proceed with operation?", fn() {
          status.val = "Confirmed"
        }).on_cancel(fn() { status.val = "Cancelled" })
        dialog.show(Some(open_confirm_id))
      }
      let open_custom = fn() {
        // Custom content: input + buttons
        let input_ref = Ref::new("")
        let input = @widget.TextInput::new(input_ref).width(30.0)
        let ok = @widget.Button::primary("OK", fn() {
          status.val = "Input: \{input_ref.val}"
          let _ = @widget.ModalManager::pop_modal()

        })
        let cancel = @widget.Button::secondary("Cancel", fn() {
          status.val = "Custom modal cancelled"
          let _ = @widget.ModalManager::pop_modal()

        })
        let content = @widget.Column::new([
          @widget.Text::new("Enter value:"),
          input,
          @widget.Row::new([ok, cancel]).spacing(2.0),
        ]).spacing(1.0)
        let modal = @widget.Modal::new(content)
          .with_title("Custom Modal")
          .with_size(40, 8)
          .with_backdrop(true, false)
        modal.show(Some(open_custom_id))
      }
      fn build_ui() -> @view.View {
        let header = @view.View::text("Modal Demo", color=@core.Color::Cyan)
        let hint = @view.View::text(
          "Tab/Shift+Tab cycle in modal, Esc closes. Press buttons to open.",
          color=@core.Color::Gray,
        )
        let btns = @widget.Row::new([
          @widget.Button::primary("Open Confirm", open_confirm).with_id(
            open_confirm_id,
          ),
          @widget.Button::secondary("Open Custom", open_custom).with_id(
            open_custom_id,
          ),
        ]).spacing(2.0)
        let status_line = @view.View::text(
          "Status: \{status.val}",
          color=@core.Color::Yellow,
        )
        @view.View::container_views([header, hint, btns.render(), status_line])
        .direction(@view.Direction::Column)
        .spacing(1.0)
        .padding(2.0)
      }

      @runtime.run_event_loop(
        app,
        build_ui,
        on_global_event=fn(event) {
          match event {
            @ffi.InputEvent::Key(@ffi.KeyEvent::Char(113)) => false // 'q'
            @ffi.InputEvent::Key(@ffi.KeyEvent::Escape) => false
            _ => false // Do not prevent default for other keys
          }
        },
        debug_mouse=true,
      )
      app.cleanup()
    }
  }
}
