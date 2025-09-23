#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -d "$ROOT_DIR/src/ffi/vendor/yoga" ]; then
  echo "[onebit-yoga] Vendor not found; fetching …"
  bash "$ROOT_DIR/scripts/vendor_fetch.sh" || true
else
  echo "[onebit-yoga] Vendor present; nothing to do."
fi

exit 0

