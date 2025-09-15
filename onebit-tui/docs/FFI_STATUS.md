# FFI Status Comparison

## Core Functions We Have ✅

### Renderer

- ✅ createRenderer (with wrapper for testing param)
- ✅ destroyRenderer
- ✅ setBackgroundColor
- ✅ render
- ✅ getNextBuffer / getCurrentBuffer
- ✅ resizeRenderer
- ✅ enableMouse / disableMouse
- ✅ setCursorPosition / setCursorStyle / setCursorColor

### Buffer Operations

- ✅ bufferClear (as bufferClearMB)
- ✅ bufferDrawText (as bufferDrawTextMB)
- ✅ bufferFillRect (as bufferFillRectMB)
- ✅ bufferDrawBox (as bufferDrawBoxMB)
- ✅ bufferSetCellWithAlphaBlending (as bufferSetCellWithAlphaBlendingMB)
- ✅ createOptimizedBuffer
- ✅ destroyOptimizedBuffer
- ✅ getBufferWidth / getBufferHeight

### Terminal Operations

- ✅ getTerminalSize
- ✅ setTerminalRawMode / restoreTerminalMode
- ✅ readKeyByte
- ✅ isInputAvailable

## Missing Functions (TypeScript has, we don't) ❌

### Buffer Advanced Operations

- ❌ bufferGetCharPtr / bufferGetFgPtr / bufferGetBgPtr / bufferGetAttributesPtr
  - Direct pointer access - may not be needed in MoonBit
- ❌ bufferPushScissorRect / bufferPopScissorRect / bufferClearScissorRects
  - Clipping regions for advanced rendering
- ❌ bufferGetId / bufferSetRespectAlpha / bufferGetRespectAlpha
  - Buffer metadata
- ❌ bufferResize
  - Dynamic buffer resizing
- ❌ bufferSetCell
  - Single cell manipulation (we have SetCellWithAlphaBlending)

### TextBuffer Operations

- ❌ createTextBuffer / destroyTextBuffer
- ❌ textBufferGetCharPtr / textBufferGetFgPtr / textBufferGetBgPtr
- ❌ textBufferSetCell / textBufferWriteChunk
- ❌ bufferDrawTextBuffer
  - Advanced text rendering with wrapping and formatting

### Hit Testing (for mouse interactions)

- ❌ addToHitGrid / checkHit / dumpHitGrid
  - Required for proper mouse event targeting

### Debug & Diagnostics

- ❌ setDebugOverlay
- ❌ dumpBuffers / dumpStdoutBuffer
- ❌ getTerminalCapabilities / processCapabilityResponse

### Kitty Protocol

- ❌ enableKittyKeyboard / disableKittyKeyboard
  - Advanced keyboard protocol support

## Assessment

**Our FFI is about 70% complete** for basic TUI functionality:

- ✅ Can render text, boxes, colors
- ✅ Can handle basic keyboard input
- ✅ Can manage terminal state
- ⚠️ Limited mouse support (no hit testing)
- ❌ No advanced text layout (TextBuffer)
- ❌ No clipping regions
- ❌ No debug overlays

## Recommendation

Our FFI is **sufficient to continue** with API design because:

1. Core rendering works
2. Basic input works
3. Missing features can be added incrementally

Priority additions needed:

1. Hit testing for proper mouse support
2. TextBuffer for advanced text rendering
3. Scissor rects for clipping (needed for scrollable areas)

The ideal API design in IDEAL_API_DESIGN.md can be implemented with our current FFI, and we can add missing functions as needed.
