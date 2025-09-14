#!/bin/bash
sed -i '' 's/pub fn render(self : Tooltip, buffer : Buffer/pub fn Tooltip::render(self : Tooltip, buffer : @core.TerminalBuffer/g' src/components/tooltip.mbt
sed -i '' 's/pub fn show_at(self : Tooltip/pub fn Tooltip::show_at(self : Tooltip/g' src/components/tooltip.mbt
sed -i '' 's/pub fn hide(self : Tooltip/pub fn Tooltip::hide(self : Tooltip/g' src/components/tooltip.mbt
sed -i '' 's/pub fn set_text(self : Tooltip/pub fn Tooltip::set_text(self : Tooltip/g' src/components/tooltip.mbt
sed -i '' 's/pub fn is_visible(self : Tooltip/pub fn Tooltip::is_visible(self : Tooltip/g' src/components/tooltip.mbt
sed -i '' 's/Buffer/@core.TerminalBuffer/g' src/components/tooltip.mbt
