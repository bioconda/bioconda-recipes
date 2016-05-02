#!/bin/bash

binaries="\
metaphlan2.py \
utils/metaphlan2krona.py
"

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin; done
