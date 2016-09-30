#!/bin/bash

cd $SRC_DIR/

mkdir -p $PREFIX/bin

make

binaries="\
e-PCR \
famap \
fahash \
re-PCR \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

