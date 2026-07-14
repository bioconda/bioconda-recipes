#!/bin/bash
set -e
DEST="$PREFIX/share/staphscope/modules/sccmec_module"
mkdir -p "$DEST"
cp -r $SRC_DIR/* "$DEST/"
