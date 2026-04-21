#!/bin/bash
set -e
cd "$SRC_DIR"
# If there is exactly one subdirectory, step into it
if [ $(ls -1 | wc -l) -eq 1 ] && [ -d "$(ls -1)" ]; then
    cd "$(ls -1)"
fi
DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -r ./* "$DEST/"
