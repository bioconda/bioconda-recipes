#!/bin/bash
set -e

cd "$SRC_DIR"
DEST="$SP_DIR/ecoliTyper/modules/CHTyper_module"
mkdir -p "$DEST"
cp -r ./* "$DEST/"
