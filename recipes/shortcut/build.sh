#!/bin/bash
set -eu -o pipefail

# specify and create /bin/ directory
BINDIR=$PREFIX/bin
mkdir -p $BINDIR

cp "$SRC_DIR/ShortCut.py" "$BINDIR/ShortCut"

chmod +x "$BINDIR/ShortCut"
