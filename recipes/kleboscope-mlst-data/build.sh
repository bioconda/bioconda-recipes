#!/bin/bash
set -e

cd "$SRC_DIR"

# If there is exactly one subdirectory, step into it
subdir=$(find . -maxdepth 1 -type d ! -name . | head -1)
if [ -n "$subdir" ]; then
    cd "$subdir"
fi

DEST="$SP_DIR/kleboscope/modules/kleb_mlst_module"
mkdir -p "$DEST"
cp -r ./* "$DEST/"
