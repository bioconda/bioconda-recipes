#!/bin/bash
set -euxo pipefail

export CARGO_HOME="${BUILD_PREFIX}/.cargo"

cargo build --release --verbose

mkdir -p "${PREFIX}/bin"

# Find the binary regardless of target triple
BINARY=$(find target -name "emits" -type f -executable | head -1)
if [ -z "$BINARY" ]; then
    echo "ERROR: Could not find emits binary in target/"
    find target -type f -name "emits*" || true
    exit 1
fi

echo "Installing from: $BINARY"
install -m 755 "$BINARY" "${PREFIX}/bin/emits"