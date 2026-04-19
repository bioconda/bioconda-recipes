#!/bin/bash
set -e
set -x

echo "=== SRC_DIR = $SRC_DIR"
ls -la "$SRC_DIR"

SCCMEC_DIR=$(find "$SRC_DIR" -type d -name "sccmec_module" | head -1)
echo "SCCMEC_DIR = $SCCMEC_DIR"

if [ -z "$SCCMEC_DIR" ]; then
    echo "ERROR: sccmec_module not found"
    exit 1
fi

DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -rv "$SCCMEC_DIR" "$DEST/"
echo "=== Copy completed"
