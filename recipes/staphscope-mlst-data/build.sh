#!/bin/bash
set -e

MLST_DIR=$(find "$SRC_DIR" -type d -name "mlst_module" | head -1)
if [ -z "$MLST_DIR" ]; then
    echo "ERROR: Could not find mlst_module directory in $SRC_DIR"
    exit 1
fi

DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -r "$MLST_DIR" "$DEST/"
