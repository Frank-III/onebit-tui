///| Minimal Yoga layout demo for OneBit-TUI

fn run_yoga_layout_demo(renderer : Renderer) -> Unit {
  let view = box(
    title=Some("Yoga Box"),
    padding=2,
    children=[
      vstack([
        text("Top area", color=RGBA::rgb(0.9,0.9,0.2)),
        hstack([
          text("Left"),
          text("Right")
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
