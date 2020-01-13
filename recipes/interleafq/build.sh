#!/bin/bash
# For BioConda

mkdir -p "$PREFIX/bin"

chmod +x "$SRC_DIR/script/interleafq.pl"
mv       "$SRC_DIR/script/interleafq.pl" "$PREFIX/bin/interleafq"
