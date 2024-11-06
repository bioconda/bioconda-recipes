#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o xtrace

mkdir -vp "${PREFIX}/bin"

if ! install -v -m 0755 "$SRC_DIR/halfdeep.sh" "$PREFIX/bin/halfdeep.sh"; then
    echo "Failed to install halfdeep bash script" >&2
    exit 1
fi

if ! install -v -m 0755 "$SRC_DIR/halfdeep.r" "$PREFIX/bin/halfdeep.r"; then
    echo "Failed to install halfdeep r script" >&2
    exit 1
fi

if ! install -v -m 0755 "$SRC_DIR/scaffold_lengths.py" "$PREFIX/bin/scaffold_lengths.py"; then
    echo "Failed to install halfdeep python script" >&2
    exit 1
fi
