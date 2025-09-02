# MoonBit Yoga Layout Bindings

MoonBit bindings for Facebook's Yoga layout engine.

## Prerequisites

- MoonBit compiler (`moon`)
- C++ compiler (clang++ or g++)
- CMake (for building Yoga)
- [just](https://github.com/casey/just) command runner

### Installing just

```bash
# On macOS with Homebrew
brew install just

# On Linux/macOS with curl
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# With cargo
cargo install just
```

## Quick Start

```bash
# Clone the repository
git clone <repository-url>
cd onebit-yoga

# One-time setup (builds Yoga library)
just setup

# Build the project
just build

# Run tests
just test

# Clean build artifacts
just clean
```

## Available Commands

Run `just` to see all available commands:

```bash
just --list
```

### Core Commands

- `just setup` - One-time setup for new contributors
- `just build` - Build the MoonBit project
- `just test` - Run all tests
- `just clean` - Clean build artifacts (preserves Yoga library)
- `just clean-all` - Deep clean including Yoga library

### Development Commands

- `just check` - Check syntax without building
- `just info` - Show build information
- `just run <example>` - Run a specific example

## Project Structure

```
onebit-yoga/
├── justfile           # Build automation
├── build_yoga.sh      # Yoga library build script
├── moon.mod.json      # MoonBit project file
├── src/
│   ├── ffi/          # FFI bindings
│   ├── types/        # Type definitions
│   └── wrapper/      # High-level wrapper
└── yoga-install/     # Built Yoga library (generated)
    ├── include/      # C++ headers
    └── lib/          # Static library
```

## How It Works

The build system uses `just` to manage the complex build process:

1. **Yoga Library Build**: The C++ Yoga library is built once and cached in `yoga-install/`
2. **Path Resolution**: Build scripts create symlinks to resolve the library paths correctly
3. **MoonBit Compilation**: The MoonBit compiler uses the paths in `moon.pkg.json` to find the library

## Troubleshooting

### Library not found errors

If you get linking errors, ensure the Yoga library is built:

```bash
just build-yoga
```

### Clean build

For a completely fresh build:

```bash
just clean-all
just build
```

## Contributing

1. Fork the repository
2. Create your feature branch
3. Run `just test` to ensure tests pass
4. Commit your changes
5. Push to the branch
6. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
