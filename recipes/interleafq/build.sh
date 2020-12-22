#!/bin/bash
# For BioConda
set -x
mkdir -p "$PREFIX/bin"

chmod +x "$SRC_DIR/scripts/interleafq.pl"
mv       "$SRC_DIR/scripts/interleafq.pl" "$PREFIX/bin/interleafq"
