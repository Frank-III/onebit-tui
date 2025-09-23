#!/bin/bash

# Run the box demo directly
cd "$(dirname "$0")"

# Build and run
ONEBIT_SKIP_PREBUILD=1 moon build --target native && \
./target/native/release/build/demo/demo.native

# Note: This will run the main demo launcher. To test box_demo specifically,
# we would need to modify main.mbt to call main_box_demo() directly