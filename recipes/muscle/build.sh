#!/bin/bash

make CC=$CC CXX=$CXX

binaries="\
muscle \
"

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
