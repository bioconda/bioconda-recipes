#!/bin/bash

cd $SRC_DIR/bin

binaries="\
seqan_tcoffee \
"
mkdir -p $PREFIX/bin

for i in $binaries; do cp $SRC_DIR/bin/$i $PREFIX/bin/$i && chmod a+x $PREFIX/bin/$i; done
