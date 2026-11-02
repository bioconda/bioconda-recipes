#!/bin/bash
set -euo pipefail

echo "== ecolityper-mge-data build =="

DEST="$PREFIX/share/ecolityper/modules/mge_module/mobileOG-db/beatrix-1-6_v1_all"
mkdir -p "$DEST"

BEATRIX_DIR=$(find "$SRC_DIR" -type d -name "beatrix-1-6_v1_all" | head -n 1)
if [ -z "$BEATRIX_DIR" ]; then
    echo "ERROR: beatrix-1-6_v1_all not found under $SRC_DIR" >&2
    find "$SRC_DIR" -maxdepth 4 -type d >&2
    exit 1
fi

echo "Source: $BEATRIX_DIR"
echo "Dest:   $DEST"
ls -lh "$BEATRIX_DIR"

cp -r "$BEATRIX_DIR/." "$DEST/"

test -f "$DEST/mobileOG-db-beatrix-1.6.dmnd"
echo "== OK: $(du -sh "$DEST" | cut -f1) =="
