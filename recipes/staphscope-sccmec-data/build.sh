#!/bin/bash
set -e
set -x
echo "=== SRC_DIR = $SRC_DIR"
ls -la "$SRC_DIR"
DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -r $SRC_DIR/sccmec_module "$DEST/"
