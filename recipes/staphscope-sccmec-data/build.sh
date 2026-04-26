#!/bin/bash
set -e

# Create the destination database folder (tool expects a 'database' subdirectory)
DEST="$PREFIX/share/staphscope/modules/sccmec_module/database"
mkdir -p "$DEST"

# Copy all contents from SRC_DIR into DEST
# (The tarball contains the database files directly)
cp -r $SRC_DIR/* "$DEST/"
