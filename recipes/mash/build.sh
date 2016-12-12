#!/bin/bash

cd $SRC_DIR/

mkdir -p $PREFIX/bin

binaries="\
mash \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done