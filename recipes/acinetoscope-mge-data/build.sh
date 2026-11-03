#!/bin/bash
set -euo pipefail
DEST="$PREFIX/share/acinetoscope/modules/mge_module/mobileOG-db"
mkdir -p "$DEST"
DMND_FILE=$(find "$SRC_DIR" -type f -iname "mobileOG-db-beatrix-1.6.dmnd" | head -n 1)
if [ -z "$DMND_FILE" ]; then
    echo "ERROR: mobileOG-db-beatrix-1.6.dmnd not found under $SRC_DIR" >&2
    find "$SRC_DIR" -maxdepth 5 -type f >&2
    exit 1
fi
BEATRIX_DIR=$(dirname "$DMND_FILE")
PARENT=$(dirname "$BEATRIX_DIR")
echo "Source: $PARENT"
echo "Dest:   $DEST"
cp -r "$PARENT/." "$DEST/"
ls -lh "$DEST" "$DEST"/beatrix-1-6_v1_all 2>/dev/null || true
test -f "$DEST/beatrix-1-6_v1_all/mobileOG-db-beatrix-1.6.dmnd"
echo "== OK =="
