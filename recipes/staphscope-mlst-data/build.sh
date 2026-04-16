#!/bin/bash
set -e

# Destination directory for mlst_module
DEST="$PREFIX/share/staphscope/modules/mlst_module"
mkdir -p "$DEST"

# Copy all contents from SRC_DIR (these are the mlst_module files) into DEST
cp -r $SRC_DIR/* "$DEST/"
