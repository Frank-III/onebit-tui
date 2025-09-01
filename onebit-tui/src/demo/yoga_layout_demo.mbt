///| Minimal Yoga layout demo for OneBit-TUI

fn run_yoga_layout_demo(renderer : @core.Renderer) -> Unit {
  let view = @core.box(
    title=Some("Yoga Box"),
    padding=2,
    children=[
      @core.vstack([
        @core.text("Top area", color=@core.RGBA::rgb(0.9,0.9,0.2)),
        @core.hstack([
          @core.text("Left"),
          @core.text("Right")
        ])
      ])
    ]
  )

  match @ffi.Renderer::new(80, 24) {
    Some(r) => {
      // Not used here; we already received renderer; show one-shot draw via renderer's FFI buffer
      r.destroy()
    }
    None => ()
  }

  renderer.clear()
  renderer.render_view(view)
  renderer.present()
}
