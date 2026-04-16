#!/bin/bash
set -e

# Find the directory containing mec_database_20171117.fasta
DB_DIR=$(find $SRC_DIR -type f -name "mec_database_20171117.fasta" -exec dirname {} \; | head -1)
if [ -z "$DB_DIR" ]; then
    echo "ERROR: mec_database_20171117.fasta not found in $SRC_DIR"
    exit 1
fi

DEST="$SP_DIR/staphscope/modules/sccmec_module"
mkdir -p "$DEST"
cp -r "$DB_DIR" "$DEST/"
