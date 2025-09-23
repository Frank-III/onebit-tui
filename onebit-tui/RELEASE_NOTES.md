# OneBit-TUI v0.1.0 Release Notes

## First Public Release! 🎉

OneBit-TUI is now available on mooncakes.io! This is a MoonBit port of OpenTUI with Yoga flexbox layout and native Zig rendering.

## Features

- **Flexbox Layout**: Full Yoga flexbox support via onebit-yoga
- **Native Rendering**: High-performance terminal rendering with Zig
- **Unicode Box Drawing**: Beautiful borders with customizable styles
- **Title Support**: Box titles with Left/Center/Right alignment
- **Overflow Handling**: Hidden and Scroll overflow modes with clipping
- **Input Handling**: Mouse and keyboard support
- **Theming**: Light and dark themes

## Installation

```bash
moon add Frank-III/onebit-tui
```

## Requirements

- MoonBit compiler
- Zig 0.14.x (for building native components)
- C/C++ toolchain

## Known Issues

- **FFI Annotation Warnings**: You'll see ~100 warnings about FFI annotations during compilation. These are non-critical and will be addressed in the next release. The warnings don't affect functionality.

- **Link Flags**: Due to MoonBit limitations, you need to manually add link flags in your main package:
  ```json
  "link": {
    "native": {
      "cc-link-flags": [
        "-L$(pkg-path:Frank-III/onebit-tui/ffi)/../../target/native/release/ffi",
        "-L$(pkg-path:Frank-III/onebit-yoga/yoga)/../../target/native/release/yoga",
        "-lopentui", "-lyoga"
      ]
    }
  }
  ```

## What's Next

- v0.1.1: FFI annotation fixes
- v0.2.0: More widgets (TextInput, ScrollView, etc.)
- v0.3.0: Animation support

## Examples

See the README.md for usage examples and API documentation.

## Feedback

Please report issues at: https://github.com/Frank-III/onebit-tui/issues
