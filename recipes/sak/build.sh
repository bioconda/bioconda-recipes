#!/bin/bash

cd $SRC_DIR/bin

binaries="\
sak \
"

mkdir -p $PREFIX/bin

for i in $binaries; do cp $SRC_DIR/bin/$i $PREFIX/bin && chmod a+x $PREFIX/bin/$i; done
