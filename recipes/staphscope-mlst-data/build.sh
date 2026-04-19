#!/bin/bash
set -e
set -x

echo "=== SRC_DIR = $SRC_DIR"
ls -la "$SRC_DIR"

# Find mlst_module
MLST_DIR=$(find "$SRC_DIR" -type d -name "mlst_module" | head -1)
echo "MLST_DIR = $MLST_DIR"

if [ -z "$MLST_DIR" ]; then
    echo "ERROR: mlst_module not found"
    exit 1
fi

DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -rv "$MLST_DIR" "$DEST/"
echo "=== Copy completed"
