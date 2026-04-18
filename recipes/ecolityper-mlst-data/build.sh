#!/bin/bash
set -e

cd "$SRC_DIR"
DEST="$SP_DIR/ecoliTyper/modules/mlst_module"
mkdir -p "$DEST"
cp -r bin db perl5 scripts "$DEST/"
