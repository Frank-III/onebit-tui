# OneBit Status (Codex)

Current snapshot of MoonBit package health (native target), with per‑subpackage build/test status, key issues, and recommended next steps.

Legend:
- ✅ build ok
- ❌ test failed
- 🚫 run failed/not applicable
- ⚠️ warnings present (non-blocking)

## Overview

- onebit-yoga: ✅ builds; ❌ tests and 🚫 runs fail due to linker configuration (relative cc-link-flags) and macOS deployment target mismatch warnings.
- onebit-tui: ✅ builds; ❌ tests fail due to missing OpenTUI link flags and API/type mismatches in helpers/components; 🚫 run blocked until FFI linking is configured.

---

## onebit-yoga (MoonBit Yoga Layout Bindings)

Sub-packages scanned:
- `src/types` — ✅ build, ❌ test
- `src/ffi` — ✅ build, ❌ test
- `src/wrapper` — ✅ build, ❌ test
- `src/examples` — ✅ build, ❌ test; 🚫 run failed with raw `moon run` due to link flags

What works
- Core MoonBit bindings and high-level wrapper compile cleanly (native).
- Examples and tests compile to MI, but link step fails in test/run contexts.

Primary issues
- 🔗 Relative link flags break test/run linking:
  - `src/ffi/moon.pkg.json` uses `cc-link-flags: "./libyoga_wrap.a ../../yoga-install/lib/libyogacore.a -lc++"`
  - `src/examples/moon.pkg.json` uses `cc-link-flags: "./src/ffi/libyoga_wrap.a ./yoga-install/lib/libyogacore.a -lc++"`
  - From test build dirs (e.g., `target/native/debug/test/...`), these relative paths don’t resolve, yielding:
    - `clang: error: no such file or directory: './libyoga_wrap.a'`
    - `Undefined symbols for architecture arm64: _YGConfigNew_wrap, _YGNodeCalculateLayout_wrap, ...`
- 🧩 macOS deployment target warnings during link (objects built for 26.0 vs link at 16.0). Not fatal but noisy and can hide real errors.

Run status
- `moon run --target native src/examples/main.mbt` fails when invoked with current relative link flags. Earlier, a run can succeed when link flags point to the correct absolute locations (e.g., after `just setup && just build` in a shell where paths are correct), but reliability requires fixing link flags.

Recommended fixes
- Replace relative `cc-link-flags` with `link.native.flags` using absolute `-L<abs_path> -lyoga_wrap -lyogacore -lc++`, or centralize linking in `src/ffi` and remove per-example link flags.
- Normalize macOS deployment target (e.g., pass `-mmacosx-version-min=<min>` consistently when building `yoga_wrap.o`, `libyogacore.a`, and MoonBit test binaries).
- After link fixes, re-run `moon test --target native` in each subpackage, then run examples via:
  - `moon run --target native src/examples/main.mbt`

---

## onebit-tui (MoonBit TUI)

Sub-packages scanned:
- `src/ffi` — ✅ build, ❌ test
- `src/core` — ✅ build, ❌ test
- `src/components` — ✅ build, ❌ test
- `src/helpers` — ✅ build, ❌ test
- `src/reactive` — ✅ build, ❌ test
- `src/demo` — ✅ build (⚠️ many deprecations), 🚫 run (invocation + linking)

What works
- FFI bindings compile; renderer/view FFI code compiles; reactive system compiles.
- Full project `moon build --target native` succeeds.

Primary issues
- 🔗 Missing OpenTUI link configuration in `src/ffi/moon.pkg.json`:
  - File is empty, so tests that reference FFI symbols fail to link with errors like:
    - `Undefined symbols for architecture arm64: _createRendererDebug, _createOptimizedBuffer, _bufferClearMB, _bufferDrawTextMB, _bufferFillRectMB, ...`
- 🧩 API/type mismatches in helpers/components (show up in aggregate tests):
  - `helpers/layout.mbt` uses `@core.Renderable` (undefined); core exposes `BaseRenderable`.
  - Methods like `Box::set_width/set_height` are referenced in helpers/tests but not implemented on components.
  - Compiler also flags non-ignored returned values (e.g., `group.add_child(child)`), requiring explicit `ignore(...)` or assignment.
- ⚠️ Deprecation warnings (e.g., `to_uint/to_int` → `reinterpret_as_uint/int`, `.sin()`/`.cos()` → `@math.sin/cos`). Non-blocking.

Run status
- `moon run --target native -C src/demo` as attempted here failed due to CLI usage (requires a package or file arg). Even with the correct file, run will fail until FFI link flags are supplied (same undefined symbol set).
- The `just` tasks hint at `build_ffi.sh` + local libs in `onebit-tui/lib/`; until `src/ffi/moon.pkg.json` links against these, tests/run will fail.

Recommended fixes
1) Add link flags to `src/ffi/moon.pkg.json`:
- Example (adjust paths to your repo root):
  - `link.native.flags`: `-L<repo>/onebit-tui/lib -lopentui_ffi -lopentui -lterminal`
  - Consider `-Wl,-rpath,<repo>/onebit-tui/lib` for runtime.
2) Align helpers/components with core API:
- Use `@core.BaseRenderable` (or re-export an alias) in `helpers/layout.mbt`.
- Implement or remove use of `Box::set_width/set_height`; make return values explicitly ignored where needed.
3) After linking and API alignment, re-run:
- `moon test --target native -C src/ffi`
- `moon test --target native -C src/reactive`
- `just run` (which wraps building demo + running the compiled exe) or `moon run --target native src/demo/<file>.mbt`.

---

## Parity with Go/TS (Targets)

Renderer/Buffer FFI parity
- ✅ Implemented: create/destroy renderer; double-buffering; clear/draw text/fill rect; draw box; framebuffer blit; packed/supersampled buffers; cursor/mouse/resize controls; stats/memory update APIs.
- ⏳ Link config missing blocks tests/run from validating these capabilities end-to-end.

Layout parity
- ✅ Yoga bindings exist and map to Yoga enums; high-level wrapper with builder is implemented.
- ⏳ TUI view layout currently uses simple splits; needs Yoga integration to compute real bounds.

Input parity
- ✅ Rich key/mouse/resize parsing in FFI.
- ⏳ Dispatch model (focus/hit-test) not wired into views/components.

---

## Suggested Dispatch Plan (Next Jobs)

1) onebit-yoga linking (tests/run)
- Convert relative `cc-link-flags` to absolute `-L/-l` under `link.native.flags`, centralize in `src/ffi`, and remove duplicate per-example link flags.
- Normalize macOS deployment target across all Yoga artifacts and test binaries.

2) onebit-tui FFI linking
- Add `link.native.flags` in `src/ffi/moon.pkg.json` to link local OpenTUI libs in `onebit-tui/lib` (and set rpath if using dylibs).

3) Align helpers/components with core API
- Update helpers to reference `BaseRenderable` (or re-export a `Renderable` alias) and explicitly handle returned values.
- Implement missing setters or update tests to the current API surface.

4) Integrate Yoga into view_ffi layout
- Create Yoga nodes for view trees, call `calculate_layout`, then render children within computed rects.

5) Re-run and expand tests
- After link/API fixes, run `moon test --target native` package-by-package; add golden FFI tests for text/box/framebuffer and a basic event loop demo.

---

## Commands Used (native)

Per subpackage (build/test):
- `moon build --target native -C <pkg>`
- `moon test  --target native -C <pkg>`

Run examples/demos:
- Yoga: `moon run --target native src/examples/main.mbt` (requires fixed link flags)
- TUI: `moon build --target native -C src/demo` then `moon run --target native <demo-file>.mbt` (or `just run` after linking)

---

## Representative Errors

onebit-yoga (tests/run):
```
clang: error: no such file or directory: './libyoga_wrap.a'
Undefined symbols for architecture arm64: _YGConfigNew_wrap, _YGNodeCalculateLayout_wrap, ...
```

onebit-tui (ffi tests):
```
Undefined symbols for architecture arm64:
  _createRendererDebug, _createOptimizedBuffer, _bufferClearMB,
  _bufferDrawTextMB, _bufferFillRectMB, ...
```

onebit-tui (helpers/components tests):
```
The type @core.Renderable is undefined (helpers/layout.mbt)
Type components.Box has no method set_width/set_height
This expression’s value cannot be implicitly ignored (group.add_child(...))
```

---

If you’d like, I can apply the link configuration updates first (no functional code changes) to get green builds/tests where possible, then circle back to API alignment and Yoga→TUI layout wiring.

