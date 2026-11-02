#!/bin/bash
set -euo pipefail

DEST="$PREFIX/share/ecolityper/modules/mge_module/mobileOG-db/beatrix-1-6_v1_all"
mkdir -p "$DEST"

# The release zip contains a top-level directory; adjust if your archive
# layout differs.
if [ -d "$SRC_DIR/beatrix-1-6_v1_all" ]; then
    cp -r "$SRC_DIR/beatrix-1-6_v1_all/." "$DEST/"
else
    cp -r "$SRC_DIR/." "$DEST/"
fi

# Sanity check that the two files the orchestrator needs are present
test -f "$DEST/beatrix-1-6_v1_all.dmnd"
test -f "$DEST/beatrix-1-6_v1_all.faa"
