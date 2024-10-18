#!/bin/bash -e
set -uex

mkdir -vp ${PREFIX}/bin

make VERBOSE=1 -j ${CPU_COUNT}

cp "$SRC_DIR/genodsp" "$PREFIX/bin"
chmod ua+x "$PREFIX/bin/genodsp
