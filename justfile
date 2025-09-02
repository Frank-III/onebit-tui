#!/usr/bin/env just --justfile

# Default shows available commands
default:
  @just --list

# Top-level run alias
run:
  just -f onebit-tui/justfile run

# OneBit TUI shortcuts
tui-build:
  just -f onebit-tui/justfile build

tui-run:
  just -f onebit-tui/justfile run

tui-run-interact:
  just -f onebit-tui/justfile run-interact

tui-build-ffi:
  just -f onebit-tui/justfile build-ffi

tui-check:
  just -f onebit-tui/justfile check

# OneBit Yoga shortcuts
yoga-build:
  just -f onebit-yoga/justfile build

yoga-build-yoga:
  just -f onebit-yoga/justfile build-yoga

yoga-check:
  just -f onebit-yoga/justfile check

yoga-info:
  just -f onebit-yoga/justfile info
