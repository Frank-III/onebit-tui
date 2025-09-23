# OneBit‑TUI Big Picture and Execution Plan

This document captures where we are, what we’re building, and a staged, high‑signal plan. It favors lots of small, high‑priority tasks that keep the build green and the API cohesive.

## Vision

A MoonBit port of OpenTUI that:
- Uses the upstream Zig/C renderer via native FFI (no wasm).
- Uses Yoga for layout (via `onebit-yoga`).
- Exposes a minimal, composable MoonBit API: View + small DSL.
- Stays in lockstep with upstream changes by keeping our FFI thin and APIs compatible.

## Architecture Layers (Top → Bottom)
- App Layer (`core/App`): lifecycle, buffer swap, simple drawing helpers.
- Components (`components/View` + DSL): declarative UI, Yoga-backed layout, borders/backgrounds/text.
- Layout (`onebit-yoga`): Yoga wrapper and FFI (Config, Node, Value, Gap, Measure).
- Renderer/FFI (`ffi`): bindings to OpenTUI Zig/C renderer and terminal control.

## Current Status Snapshot
- FFI: Working; renderer creation, buffers, drawing, cursor, mouse hit-grid.
- Yoga wrapper: Working; size/position/flex/align/margin/padding; gap support ADDED.
- Components: View + DSL working; unified on Yoga `@types.Value` (no custom size enum).
- Demo: One minimal demo (`src/demo/view_quick_demo.mbt`) that renders a Yoga-based layout.
- Removed/disabled: Old TUI Element API, large set of stale demos; no build cycles.
- Build: Native target only (`moon build --target native`).

## Design Tenets
- Flex‑first: users rarely set fixed sizes; Yoga computes layout.
- Thin FFI: keep C/Zig surface close to upstream; adapt in View/DSL.
- Small surface: View is the primary primitive; DSL adds ergonomic helpers.
- Compile‑safety: prefer `@types.Value` for sizing, typed enums for layout.
- Keep it working: delete/trim broken paths, add features in small increments.

---

## High‑Priority Small Tasks (Do First)
Small, low‑risk, high‑impact tasks that keep velocity while preserving stability.

1) Text sizing polish (single line)
- Goal: ensure `View::text(...)` intrinsic size is consistent across fonts/terminals.
- Work: keep current width = `content.length()`, height = 1; document monospace assumption; add TODO hook for measure.
- Acceptance: text views align predictably in rows/columns without clipping.

2) Wrapped text helper (done)
- Status: `View::text_wrapped(content, max_width, color?)` implemented with simple word wrapping; sets width/height automatically.
- Follow‑ups: support newline characters; basic justification options (left by default).

3) Gap ergonomics (done)
- Status: Yoga gap via Gutter (All/Row/Column) wired: `View::gap/row_gap/column_gap`.
- Acceptance: gaps are visible and consistent in the demo.

4) Warning budget trim (ongoing)
- Work: replace deprecated casts with `reinterpret_as_*` (done in terminal_input); modernize typealiases; remove dead helpers.
- Acceptance: Build has 0 errors and low, known warnings.

5) Docs refresh (started)
- Work: `components/README.mbt.md` with simple, idiomatic examples; add this roadmap.
- Acceptance: New contributors can build a two‑panel layout in <5 minutes by copying examples.

6) Build hygiene
- Work: keep only native builds; validate link flags and rpath; ensure `libyoga_wrap.a` rebuild notes are in `onebit-yoga/build_yoga.sh`.
- Acceptance: Fresh clone + documented steps produce a working demo.

---

## Next: Feature Implementation (Medium)
Tasks that add concrete capability while keeping API coherent. Each should land independently.

A) Yoga measure callback (text auto‑size)
- Goal: Provide `Node::set_measure` in `onebit-yoga` and expose `View::measure_text(wrap: Bool)`.
- Work:
  - C wrapper: bridge `YGNodeSetMeasureFunc` and `YGNodeSetMeasureFunc(nullptr)`.
  - FFI/native wrapper: define callback ABI and a trampoline (handle → MoonBit fn).
  - Wrapper API: `Node::set_measure((w, wmode, h, hmode)->Size)`.
  - Components: when enabled, text views auto‑size and can reflow.
- Risks: callback ABI correctness and lifetime. Keep behind an opt‑in flag.

B) Event hooks (click/keys) – minimal path
- Goal: Per‑View `.on_click` using existing hit-grid.
- Work: map Yoga layout to hit-grid rectangles; invoke stored closures on hit.
- Scope: start with click only; later add key/focus.

C) Theming v0
- Goal: Tiny theme struct with palette (fg/bg/accent); add `.theme(theme)` on root View.
- Work: map to color helpers only; no global state.

D) More components via composition
- Goal: Buttons, inputs, lists using View + text helpers (no new layout engine).
- Work: visual states only; events plugged in after B).

E) Scrolling container (simple)
- Goal: Clip + offset child rendering; use existing buffer scissor.
- Work: push/pop scissor; track scroll offset; arrows to scroll later (after events).

---

## Later: Advanced / Harder Items
- Async/event loop integration with proper input handling and redraw coalescing.
- Performance: batch draw calls; measure/optimize hot paths.
- Accessibility/IME considerations for text input.
- Cross‑platform terminal quirks (kitty, tmux, Windows); capability probing.
- Snapshot tests for rendering (character grid diffs).
- Package/versioning + CI.

---

## Decision Gates (Loop Humans In)
- Any breaking API change to `View` or DSL.
- Introducing a higher‑level Element API beyond View.
- Large FFI surface changes (new C symbols / ABI decisions).
- Theming model beyond trivial palette (e.g., CSS‑like cascade).

---

## Definition of Done (per layer)
- FFI: linked, symbol‑stable, doc‑noted; round‑trip demo.
- Yoga wrapper: type‑safe, covers needed properties; build passes native.
- Components: compiles, renders in demo, docs updated; no dead code/unused demos.
- App: stable buffer swap, simple helpers; demo exercises it.

## How We Work
- Prefer deleting broken paths to patching around them.
- Land small, independently usable slices.
- Keep the demo minimal but representative.
- Native target only: `moon build --target native`.

---

## Checklist (rolling)
- [x] Gap (All/Row/Column) via Yoga gutters
- [x] Unified sizing to `@types.Value`
- [x] Pruned old demos; kept one minimal
- [x] Wrapped text helper
- [ ] Measure callback (opt‑in) for auto‑sizing text
- [x] Minimal `.on_click` with hit‑grid
- [x] Theme v0 (palette)
- [x] Scroll container (clip + offset)
- [x] Docs: quickstart + patterns

Recently completed
- [x] View ergonomics: padding_symmetric/margin_symmetric, width/height percent/auto, flex_grow/shrink, align_self/content, justify_* helpers
- [x] Text helpers: auto_size_text and auto_wrap
- [x] Composable controls v0: make_button, input_control, vlist

---

Updated: keep this file as the single source of truth for priorities; adjust as we land work.

---

## Not Done Yet — Detailed Plan (Actionable)

Below are the remaining high‑value items with concrete scope, API surface, steps, acceptance, and risks. Each is independently mergable.

### 1) Yoga Measure Callback (opt‑in) — Auto‑size Text
- Scope
  - Add `Node::set_measure((w, wmode, h, hmode) -> Size)` to `onebit-yoga`.
  - Expose `View::measure_text(wrap: Bool)` to enable per‑view auto‑sizing.
- API Surface
  - onebit-yoga/ffi (native): `YGNodeSetMeasureFunc_wrap`, `YGNodeSetMeasureFunc_clear_wrap`.
  - onebit-yoga/native: trampoline function (handle → MoonBit closure) + registration.
  - onebit-yoga/wrapper: `pub fn Node::set_measure(f: (Float, MeasureMode, Float, MeasureMode) -> Size)` and `clear_measure()`.
  - components/View: `measure_text(wrap: Bool)` toggles a measure callback that computes size from content (+ optional max width).
- Steps
  1. C wrapper: add set/clear measure functions; ensure thread‑safe static table for callbacks.
  2. Native FFI: add externs; convert MeasureMode/Size.
  3. Wrapper: expose safe API; store closure in Node; manage lifetime (clear on drop or explicit).
  4. View: when enabled, override width/height based on content; respect wrap flag + optional max width.
  5. Demo: small sample using measure vs fixed sizing.
- Acceptance
  - Text nodes size to content; passing explicit width forces wrapping when enabled.
  - No regressions for non‑measured views.
- Risks
  - Callback ABI/lifetime; mitigate with explicit `clear_measure()` and internal registry.

### 2) Minimal `.on_click` via Hit‑Grid
- Scope
  - Add per‑View on‑click callback integrating with existing hit‑grid and Yoga layout rectangles.
- API Surface
  - components/View: `.on_click((x: Int, y: Int) -> Unit)`.
  - render loop helper: after drawing, register hit regions for clickable views (`addToHitGrid`).
- Steps
  1. Add optional `id: UInt` on View; assign stable ids; helper to (re)register hit regions from computed layout.
  2. Expose `components::pump_clicks(app, root)` that resolves hits via FFI and dispatches to matching View.
  3. Wire a tiny demo: button row that logs clicks.
- Acceptance
  - Clicks on views with handlers invoke callbacks reliably; coordinates relative to the view.
- Risks
  - Region invalidation on resize; re‑register after layout pass.

Status: done for click. Next steps: keyboard/focus
- Extend to `.on_key((key: Int) -> Unit)` at App level with simple dispatch; focus management minimal (focused View ref)
- Add `focus()`/`blur()` bookkeeping; no visual states yet (theme accent underline as optional)

### 3) Theme v0 (Palette)
- Scope
  - Lightweight theme object with fg/bg/accent; root view applies theme to descendants unless overridden.
- API Surface
  - core/color remains the source of truth; add `Theme { fg, bg, accent }`.
  - components/View: `.theme(theme)` and `.use_accent()` helper for text/border.
- Steps
  1. Define `Theme` and a couple presets (light/dark).
  2. View field `theme?: Theme`; renderer helpers read from theme when local color unset.
  3. Demo: two panels with different themes.
- Acceptance
  - Setting theme at a parent affects children unless they set explicit colors.
  - No global state; explicit data flow only.
- Risks
  - None significant; purely visual.

### 4) Scroll Container (Clip + Offset)
- Scope
  - Add a `ScrollView` primitive using buffer scissor and y‑offset; no input handling yet.
- API Surface
  - components: `scroll(child: View) -> View` or `View::scrollable()` returning a wrapper view with `scroll_y: Int`.
  - render_helpers: push/pop scissor around child render.
- Steps
  1. Add `push_scissor(x,y,w,h)`/`pop_scissor()` calls around child render (use existing FFI functions).
  2. Respect `scroll_y` when drawing children.
  3. Demo: long list inside fixed area.
- Acceptance
  - Content outside the region is clipped; changing `scroll_y` changes visible section.
- Risks
  - None; uses existing FFI.

Status: offset only (no hardware clip yet)
- We attempted scissor bindings; linking shows missing symbols upstream.
- Keep API hooks; enable once upstream exposes `bufferPushScissorRect` etc.

### 5) Docs: Quickstart + Patterns
- Scope
  - Expand `components/README.mbt.md` with 3 canonical patterns: sidebar layout, grid of cards, list in a scroll area.
- Steps
  1. One code sample per pattern; no new APIs.
  2. Cross‑link to `ROADMAP.md` and build steps.
- Acceptance
  - New user can copy/paste and modify patterns to build small UIs quickly.
- Risks
  - None.

Status: done (Quickstart, sidebar, grid, scroll)

---

## TypeScript Parity Targets (Mapping → MoonBit)

Core widgets
- Box/View: parity achieved via `View` + `.border/.background/.padding/.gap`
- Text: `text`, `text_wrapped`, `auto_size_text`, `auto_wrap`
- Button: `make_button` (controls v0); TS parity later when events mature
- Input: `input_control` (display only); TS parity after key/focus/editing
- List: `vlist`; TS parity after selection + keyboard
- ScrollView: `render_scroll_content` + `View.scroll_y`; TS parity after scissor

Layout
- Flexbox: `row/column/center/justify_*` + Yoga properties (done)
- Gap: gutter support (done)
- Grid: compose rows with flex; add helper later

Events & State
- Click: done
- Keyboard/focus: next
- Editing (text input): after keyboard/focus

Theming
- v0 palette: done
- Theme cascade & variants: later

Rendering/FFI
- Scissor/clip: enable when upstream provides symbols; keep helpers ready
- Draw box/text/rect: working via MB wrappers

Testing/CI
- Snapshot rendering tests (later)
- CI build + lint (later)

---

## MoonBit API Refinements (Consistency)
- Method naming: prefer verbs for setters (`.padding_symmetric`, `.width_percent`), keep short aliases for `justify_*`
- Package exports: ensure `components` exports `controls` and `README` references helpers
- Avoid duplicate APIs (keep View/DSL primary; no parallel Element API)
