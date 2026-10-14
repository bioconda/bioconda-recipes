#!/bin/bash
set -euo pipefail

DEST="$PREFIX/share/staphscope/modules/mge_module"
mkdir -p "$DEST"

# The release tarball ships a top-level `mge_module/` directory.
# Support both flattened and wrapped archives.
SRC_MODULE=""
for candidate in "$SRC_DIR/mge_module" "$SRC_DIR"/*/mge_module; do
    if [ -d "$candidate" ]; then
        SRC_MODULE="$candidate"
        break
    fi
done

if [ -z "$SRC_MODULE" ]; then
    echo "ERROR: mge_module folder not found inside $SRC_DIR"
    echo "Directory tree:"
    find "$SRC_DIR" -maxdepth 3 -type d
    exit 1
fi

cp -r "$SRC_MODULE"/. "$DEST/"

# Sanity check that the DIAMOND database is present
DIAMOND_DB="$DEST/mobileOG-db/beatrix-1-6_v1_all/mobileOG-db-beatrix-1.6.dmnd"
if [ ! -f "$DIAMOND_DB" ]; then
    echo "ERROR: mobileOG DIAMOND database missing at $DIAMOND_DB"
    exit 1
fi
