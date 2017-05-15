#!/bin/bash

TGT="$PREFIX/share/weeder2"
[ -d "$TGT" ] || mkdir -p "$TGT"
[ -d "${PREFIX}/bin" ] || mkdir -p "${PREFIX}/bin"

cd "${SRC_DIR}"
g++ weeder2.cpp -o weeder2 -O3
cp -r FreqFiles $TGT/
cp weeder2 $TGT/

cp $RECIPE_DIR/weeder2.py $TGT/
ln -s $TGT/weeder2.py $PREFIX/bin/weeder2
chmod 0755 "${PREFIX}/bin/weeder2"
