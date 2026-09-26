#!/bin/bash
set -e
DEST="$PREFIX/share/staphscope/modules/sccmec_module_cge"
mkdir -p "$DEST"
cp -r $SRC_DIR/sccmec_module_cge/. "$DEST/"
