#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
 DASqv  \
 DAStrim
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
