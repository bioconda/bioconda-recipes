#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
 REPmask \
 datander \
 TANmask \
 HPC.REPmask \
 HPC.TANmask
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
