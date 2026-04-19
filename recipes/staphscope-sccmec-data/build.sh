#!/bin/bash
set -e

echo "=== Debug: SRC_DIR = $SRC_DIR"
ls -la $SRC_DIR

DEST="$SP_DIR/staphscope/modules/sccmec_module/database"
mkdir -p "$DEST"
echo "=== Debug: DEST = $DEST"

if [ -d "$SRC_DIR/database" ]; then
    echo "=== Found database directory, copying its contents"
    cp -rv "$SRC_DIR/database/." "$DEST/"
else
    echo "=== No database directory, copying all contents"
    cp -rv "$SRC_DIR/." "$DEST/"
fi

echo "=== Debug: Final contents of $DEST"
ls -la "$DEST"
