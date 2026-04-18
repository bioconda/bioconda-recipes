#!/bin/bash
set -e

cd "$SRC_DIR"
DATA_DIR=$(find . -maxdepth 2 -type d -name "db" -exec dirname {} \; | head -1)
if [ -z "$DATA_DIR" ]; then
    echo "ERROR: Could not find the data directory (containing db/)"
    exit 1
fi

DEST="$SP_DIR/kleboscope/modules/kleb_mlst_module"
mkdir -p "$DEST"
cp -r "$DATA_DIR"/* "$DEST/"
