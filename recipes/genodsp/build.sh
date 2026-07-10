#!/bin/bash -e
set -uex

mkdir -vp "${PREFIX}/bin"

make VERBOSE=1 -j ${CPU_COUNT}

if ! install -v "$SRC_DIR/genodsp" "$PREFIX/bin/genodsp"; then
    echo "Failed to install genodsp binary" >&2
    exit 1
fi
