#!/bin/bash
set -e

DEST="$SP_DIR/kleboscope/modules/kleb_mlst_module"
mkdir -p "$DEST"
cp -r $SRC_DIR/kleb_mlst_data/* "$DEST/"
