#!/bin/bash
set -e
set -x
echo "=== SRC_DIR = $SRC_DIR"
ls -la "$SRC_DIR"
DEST="$PREFIX/share/staphscope/modules"
echo "=== DEST = $DEST"
mkdir -p "$DEST"
cp -rv "$SRC_DIR"/* "$DEST/"
echo "=== Contents of DEST:"
ls -la "$DEST"
