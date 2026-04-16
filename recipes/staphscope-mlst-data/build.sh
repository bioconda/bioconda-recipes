#!/bin/bash
set -e

# Find the directory containing mlst_module.py
MLST_DIR=$(find $SRC_DIR -type f -name "mlst_module.py" -exec dirname {} \; | head -1)
if [ -z "$MLST_DIR" ]; then
    echo "ERROR: mlst_module.py not found in $SRC_DIR"
    exit 1
fi

# $SP_DIR is the site-packages directory of the build environment
DEST="$SP_DIR/staphscope/modules/mlst_module"
mkdir -p "$DEST"
cp -r "$MLST_DIR"/* "$DEST/"
