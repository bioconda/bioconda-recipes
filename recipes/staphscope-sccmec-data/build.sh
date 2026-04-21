#!/bin/bash
set -e

DEST="$PREFIX/share/staphscope/modules"
mkdir -p "$DEST"
cp -r $SRC_DIR/sccmec_module "$DEST/"
