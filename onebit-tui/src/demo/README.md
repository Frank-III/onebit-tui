# OneBit-TUI Demos

This directory contains demonstration programs showcasing the OneBit-TUI components and features.

## Available Demos

### 1. Interactive Test Demo (`interactive_test_demo.mbt`)

**Purpose**: Test and verify all input handling mechanisms

- Tests keyboard events (all key types)
- Tests mouse clicks with position tracking
- Tests focus management (Tab/Shift+Tab navigation)
- Real-time event logging
- Visual feedback for state changes
- Multiple interactive zones

**Features tested**:

- ✓ Keyboard handling
- ✓ Mouse events with coordinates
- ✓ Focus system
- ✓ State management with Ref[T]
- ✓ Event callbacks
- ✓ Component interactivity
- ✓ Real-time updates with text_bind

### 2. Quick Demo (`view_quick_demo.mbt`)

**Purpose**: Main showcase demo with all components

- Settings panel with checkboxes and toggles
- Table display
- List selection
- Text input
- Modal dialogs

### 3. Forms Demo (`forms_demo.mbt`)

**Purpose**: Showcase form components

- Checkboxes (single and groups)
- Radio buttons
- Select/dropdown components
- Toggle switches
- Form submission

### 4. Table Demo (`table_demo.mbt`)

**Purpose**: Demonstrate table component

- Column configuration
- Row selection
- Keyboard navigation
- Different border styles
- Alignment options

### 5. Modal Demo (`modal_demo.mbt`)

**Purpose**: Modal dialog system

- Alert modals
- Confirm dialogs
- Custom form modals
- Focus trap demonstration

### 6. Component Verification (`verify_components.mbt`)

**Purpose**: Automated testing of component functionality

- Non-interactive verification script
- Tests all core component features
- Useful for regression testing

## Running Demos

To run a demo, first set it as the main entry point by ensuring it has `fn main` while others have different names, then:

```bash
cd onebit-tui
moon build --target native
./target/native/release/build/demo/demo.exe
```

## Controls

Most demos support these common controls:

- **Tab**: Move focus forward
- **Shift+Tab**: Move focus backward
- **Arrow Keys**: Navigate lists and menus
- **Space/Enter**: Activate buttons and toggles
- **Click**: Mouse interaction
- **q**: Quit the demo

## Architecture

All demos follow the same pattern:

1. Initialize the App with `@core.App::init()`
2. Create state variables using `Ref[T]`
3. Build UI tree using View components
4. Run event loop with `@components.run_event_loop()`
5. Clean up with `app.cleanup()`

Components use MoonBit-native patterns with `Ref[T]` for state management and provide full keyboard and mouse support.
