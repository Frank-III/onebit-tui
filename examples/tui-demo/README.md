OneBit‑TUI Examples (dev‑only)

Run the example launcher:

  moon run --target native src/main.mbt

Or run an individual demo (each file defines its own main_* function):

- TabSelect: moon run --target native src/tab_select_demo.mbt
- Select:    moon run --target native src/select_demo.mbt
- TextArea:  moon run --target native src/text_area_demo.mbt
- ScrollBox: moon run --target native src/scrollbox_demo.mbt
- TextInput: moon run --target native src/input_demo.mbt
- Border Titles: moon run --target native src/border_title_demo.mbt
- Modal: moon run --target native src/modal_demo.mbt
- CodeView (syntax highlight): moon run --target native src/code_view_demo.mbt

Notes

- Focus: Press Tab/Shift+Tab to move focus between focusables.
- Exit: Press q or Esc to quit any demo.
- Mouse: Wheel/trackpad scroll works on the focused ScrollBox/TextArea.
