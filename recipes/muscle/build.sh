#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR

export PRFX=$PREFIX
make

binaries="\
muscle \
"

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done