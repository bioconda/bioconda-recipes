#!/bin/bash
set -e

echo "=== Debug: SRC_DIR = $SRC_DIR"
ls -la $SRC_DIR

cd "$SRC_DIR"

if [ $(ls -1 | wc -l) -eq 1 ] && [ -d "$(ls -1)" ]; then
    subdir=$(ls -1)
    echo "=== Entering subdirectory: $subdir"
    cd "$subdir"
fi

echo "=== Current directory contents:"
ls -la

DEST="$SP_DIR/kleboscope/modules/kleb_mlst_module"
echo "=== Destination: $DEST"
mkdir -p "$DEST"

cp -rv ./* "$DEST/"

echo "=== Final contents of DEST:"
ls -la "$DEST"
