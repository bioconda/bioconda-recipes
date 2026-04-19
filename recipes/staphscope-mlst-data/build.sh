#!/bin/bash
set -e

echo "=== Debug: SRC_DIR = $SRC_DIR"
ls -la $SRC_DIR

DEST="$SP_DIR/staphscope/modules/mlst_module"
mkdir -p "$DEST"
echo "=== Debug: DEST = $DEST"

if [ -d "$SRC_DIR/mlst_module" ]; then
    echo "=== Found mlst_module directory, copying its contents"
    cp -rv "$SRC_DIR/mlst_module/." "$DEST/"
else
    echo "=== No mlst_module directory, copying all contents"
    cp -rv "$SRC_DIR/." "$DEST/"
fi

echo "=== Debug: Final contents of $DEST"
ls -la "$DEST"
