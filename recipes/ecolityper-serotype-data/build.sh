#!/bin/bash
set -e

cd "$SRC_DIR"
DEST="$SP_DIR/ecoliTyper/modules/serotypefinder_module"
mkdir -p "$DEST"
cp -r ./* "$DEST/"
