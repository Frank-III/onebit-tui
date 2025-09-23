# Session Summary — OneBit-TUI + OneBit-Yoga Packaging and Upstream Sync (2025-09-21)

## Diagnosis: Zig 0.15 vs vendor expecting Zig 0.14
- Symptom: Building OpenTUI (vendored Zig) fails on Zig 0.15 with errors like:
  - no field named 'root_source_file' in struct 'Build.ExecutableOptions'
  - no field named 'root_source_file' in struct 'Build.TestOptions'
- Root cause: The vendored OpenTUI (and its dependency zg-0.14.1) target Zig 0.14.x. Zig 0.15 updated std.Build APIs, so simply disabling a version check isn’t enough — the build files themselves need porting.
- Conclusion: For now, use Zig 0.14.x to build OpenTUI. Porting to 0.15 requires updating build.zig and dependency versions to 0.15-compatible releases.

## What We Implemented

### OneBit-Yoga
- Public API path
  - Removed the confusing wrapper package; created src/yoga as the public MoonBit API (Node, NodeBuilder) with re-exports for enums and common FFI structs.
  - New import path: "Frank-III/onebit-yoga/yoga".
- Vendor and pre-build
  - scripts/prepare_vendor_yoga.sh: creates a trimmed Yoga vendor under src/ffi/vendor/yoga containing only CMakeLists.txt, cmake/, yoga/ sources, and LICENSE.
  - src/ffi/scripts/build_yoga.sh (pre-build):
    - Builds Yoga from the trimmed vendor tree.
    - Patches out add_subdirectory(tests) automatically (on a copied source) when tests/ is absent.
    - Prunes gtest/gmock libs, pkgconfig, and gtest/gmock includes from yoga-install to keep .mooncakes lean.
    - Builds our wrapper static lib (libyoga_wrap.a) and installs libyogacore.a.
- Examples and docs
  - Examples import { path: "…/yoga", alias: "yoga" } (+ types if enums are referenced).
  - Examples print layout via accessors (layout_left/top/width/height) to avoid relying on Show for FFI structs.
  - Updated README.md, LINKING_SOLUTION.md, and WORKING_STATE.md to reflect the new paths and link instructions.
- Publish
  - Published Frank-III/onebit-yoga v0.2.0 to the registry with vendor included so postadd is a no-op on install.

### OneBit-TUI
- Yoga import migration
  - Updated all imports from wrapper → yoga across layout, components, runtime, and demo.
  - Refactored code from @wrapper.Node to @yoga.Node.
- Zig vendor + pre-build
  - Synced vendored OpenTUI Zig sources from packages/core/src/zig into onebit-tui/src/ffi/vendor/opentui.
  - Pre-build script (src/ffi/scripts/build_opentui.sh): operates from src/ffi, forces static linkage in build.zig.
  - Temporarily disabled strict Zig version check (for local testing), but Zig 0.15 fails due to std.Build API changes in vendor/deps.
- Demo link flags cleanup
  - Simplified dev link flags to relative -L paths for local testing. For published usage, app authors link against .mooncakes/Frank-III/onebit-yoga/… per the README.

### Upstream OpenTUI Sync
- Fetched upstream/main and merged safely, restoring root package.json to avoid touching TS package settings.
- This brought in core Zig updates (e.g., text-wrap work), hence the Zig version sensitivity.

## Recommendations & Next Steps

1) Toolchain strategy for OneBit-TUI
- Short-term: Require Zig 0.14.x for OpenTUI builds
  - Re-enable the vendor zig version check and fail fast with a friendly message: “OpenTUI currently requires Zig 0.14.x; please install 0.14.1 and try again.”
  - Document this in onebit-tui’s README/DISTRIBUTION_GUIDE.
- Medium-term: Port vendored OpenTUI + zg dep to Zig 0.15
  - Update build.zig from .root_source_file/ExecutableOptions → 0.15’s .root_module patterns.
  - Bump dependency ‘zg’ to a 0.15-compatible release.
  - Re-validate exported symbols (createRenderer, createOptimizedBuffer, etc.) and adjust onebit-tui/src/ffi/opentui_wrap.c accordingly.

2) Publishing hygiene
- Continue publishing with vendor included under src/ffi/vendor to avoid network on install.
- (Optional) Exclude src/examples from registry tar if you want the smallest footprint; provide them in the repo only.

3) Developer eXperience (DX) improvements
- Add a postadd helper (optional/interactive) to inject link flags into the user’s app once, keeping control with the user.
- Crosslink OneBit-TUI README to OneBit‑Yoga README for the correct import/link steps.

## Lessons Learned for MoonBit Native Bindings
- Packaging
  - Ship vendor sources in the package; rely on pre-build to compile native artifacts on the user’s machine.
  - Avoid shipping large, unrelated content in .mooncakes: trim vendor to just what build needs; prune test/bench artifacts from installs.
- Linkage
  - MoonBit does not propagate link flags from dependencies yet. Document the exact cc/cc-link-flags for consumers to add.
- API clarity
  - Provide one clear public submodule (e.g., …/yoga) that re-exports necessary types so consumers have minimal imports.
- Toolchain compatibility
  - Vendor projects often pin a specific Zig version. Disabling version checks may reveal deeper incompatibility (std.Build API changes). Pin or port consciously.

## Action Items (Concrete)
- OneBit-TUI
  - Re-enable Zig 0.14 check in build_opentui.sh with a clear error message.
  - Add onebit-tui/DISTRIBUTION_GUIDE.md with Zig version requirement and setup steps.
  - Test on Zig 0.14 locally; patch opentui_wrap.c if Zig exports changed.
- OneBit-Yoga
  - (Optional) Add a publish script to exclude examples from the published tar if desired.

---
Generated on 2025‑09‑21.
