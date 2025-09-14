#!/bin/bash
# Fix toggle.mbt
sed -i '' 's/pub fn handle_key(self : Toggle/pub fn Toggle::handle_key(self : Toggle/g' src/components/toggle.mbt
sed -i '' 's/pub fn handle_mouse(self : Toggle, event : MouseEvent/pub fn Toggle::handle_mouse(self : Toggle, event : @core.MouseEvent/g' src/components/toggle.mbt
sed -i '' 's/pub fn set_position(self : Toggle/pub fn Toggle::set_position(self : Toggle/g' src/components/toggle.mbt
sed -i '' 's/pub fn set_size(self : Toggle/pub fn Toggle::set_size(self : Toggle/g' src/components/toggle.mbt
sed -i '' 's/pub fn focus(self : Toggle/pub fn Toggle::focus(self : Toggle/g' src/components/toggle.mbt
sed -i '' 's/pub fn blur(self : Toggle/pub fn Toggle::blur(self : Toggle/g' src/components/toggle.mbt
sed -i '' 's/pub fn is_checked(self : Toggle/pub fn Toggle::is_checked(self : Toggle/g' src/components/toggle.mbt
sed -i '' 's/pub fn set_checked(self : Toggle/pub fn Toggle::set_checked(self : Toggle/g' src/components/toggle.mbt

# Fix tree.mbt
sed -i '' 's/pub fn handle_mouse(self : Tree, event : MouseEvent/pub fn Tree::handle_mouse(self : Tree, event : @core.MouseEvent/g' src/components/tree.mbt
sed -i '' 's/Buffer/@core.TerminalBuffer/g' src/components/tree.mbt
sed -i '' 's/Buffer/@core.TerminalBuffer/g' src/components/toggle.mbt
