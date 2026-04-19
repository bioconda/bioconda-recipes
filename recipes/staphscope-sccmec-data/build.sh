#!/bin/bash
set -e

SCCMEC_DIR=$(find "$SRC_DIR" -type d -name "sccmec_module" | head -1)
if [ -z "$SCCMEC_DIR" ]; then
    echo "ERROR: Could not find sccmec_module directory in $SRC_DIR"
    exit 1
fi

DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -r "$SCCMEC_DIR" "$DEST/"
