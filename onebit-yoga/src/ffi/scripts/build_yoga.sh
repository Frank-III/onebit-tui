#!/usr/bin/env bash
set -euo pipefail

# Build Yoga (C++) static library into src/ffi/yoga-install/lib/libyogacore.a
# Executed with CWD = onebit-yoga/src/ffi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"   # points to src/ffi
INSTALL_DIR="$ROOT_DIR/yoga-install"
VENDOR_DIR_PRIMARY="$ROOT_DIR/vendor/yoga"
VENDOR_DIR_FALLBACK="$(cd "$ROOT_DIR/../../build/yoga" 2>/dev/null && pwd || true)"

if ! command -v cmake >/dev/null 2>&1; then
  echo "Error: 'cmake' not found. Please install CMake (>=3.16)." >&2
  exit 1
fi

if ! command -v make >/dev/null 2>&1; then
  echo "Error: 'make' not found." >&2
  exit 1
fi

SRC_DIR=""
if [ -d "$VENDOR_DIR_PRIMARY" ]; then
  SRC_DIR="$VENDOR_DIR_PRIMARY"
elif [ -n "$VENDOR_DIR_FALLBACK" ] && [ -d "$VENDOR_DIR_FALLBACK" ]; then
  SRC_DIR="$VENDOR_DIR_FALLBACK"
else
  echo "Error: Yoga sources not found. Expected at 'vendor/yoga' (packaged) or '../../build/yoga' (dev)." >&2
  echo "Populate vendor via scripts/vendor_fetch.sh, or place sources accordingly." >&2
  exit 1
fi

echo "[onebit-yoga] Building Yoga from: $SRC_DIR"

BUILD_DIR="$SRC_DIR/build"
mkdir -p "$BUILD_DIR"

# If building from trimmed vendor, patch out tests subdir which is pruned
if [ ! -d "$SRC_DIR/tests" ] && [ -f "$SRC_DIR/CMakeLists.txt" ]; then
  if grep -q "add_subdirectory( *tests *)" "$SRC_DIR/CMakeLists.txt"; then
    echo "Creating patched build source (skip tests) …"
    TMP_SRC="$ROOT_DIR/vendor/yoga.buildsrc"
    rm -rf "$TMP_SRC"
    mkdir -p "$TMP_SRC"
    cp -R "$SRC_DIR/" "$TMP_SRC/"
    sed -i.bak 's/^\(.*add_subdirectory( *tests *).*\)$/# \1 (pruned)/' "$TMP_SRC/CMakeLists.txt" || true
    rm -f "$TMP_SRC/CMakeLists.txt.bak" || true
    SRC_DIR="$TMP_SRC"
    BUILD_DIR="$SRC_DIR/build"
    mkdir -p "$BUILD_DIR"
  fi
fi

(
  cd "$BUILD_DIR"
  cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_TESTING=OFF \
    -DYOGA_BUILD_TESTS=OFF \
    -DYOGA_BUILD_BENCHMARKS=OFF || true

  # parallel build
  if command -v nproc >/dev/null 2>&1; then
    make -j"$(nproc)"
  elif command -v sysctl >/dev/null 2>&1; then
    make -j"$(sysctl -n hw.ncpu)"
  else
    make -j4
  fi
  make install
)

if [ ! -f "$INSTALL_DIR/lib/libyogacore.a" ]; then
  echo "Error: libyogacore.a not found in $INSTALL_DIR/lib" >&2
  exit 1
fi

echo "✓ Yoga static library ready: yoga-install/lib/libyogacore.a"

# Prune test artifacts to keep .mooncakes minimal
rm -f "$INSTALL_DIR/lib/libgtest"*.a || true
rm -f "$INSTALL_DIR/lib/libgmock"*.a || true
rm -rf "$INSTALL_DIR/lib/pkgconfig" || true
rm -rf "$INSTALL_DIR/lib/cmake/GTest" || true
rm -rf "$INSTALL_DIR/include/gtest" "$INSTALL_DIR/include/gmock" || true

# Clean patched build source if created
if [ -n "${TMP_SRC:-}" ] && [ -d "$TMP_SRC" ]; then
  rm -rf "$TMP_SRC"
fi

# Build C wrapper into a static library for Moon linking
echo "[onebit-yoga] Building Yoga FFI wrapper (libyoga_wrap.a) …"
cc -c -o "$ROOT_DIR/yoga_wrap.o" -I "$INSTALL_DIR/include" -fPIC "$ROOT_DIR/yoga_wrap.c"
ar rcs "$ROOT_DIR/libyoga_wrap.a" "$ROOT_DIR/yoga_wrap.o"
echo "✓ Wrapper static library ready: src/ffi/libyoga_wrap.a"

exit 0
