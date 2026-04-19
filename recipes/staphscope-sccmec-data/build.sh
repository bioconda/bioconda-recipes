#!/bin/bash
set -e

SCCMEC_DIR=$(find "$SRC_DIR" -type d -name "sccmec_module" | head -1)
if [ -z "$SCCMEC_DIR" ]; then
    echo "ERROR: sccmec_module not found in $SRC_DIR"
    exit 1
fi

DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -r "$SCCMEC_DIR" "$DEST/"
