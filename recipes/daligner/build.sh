#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
 daligner  \
 HPC.daligner  \
 LAsort  \
 LAmerge  \
 LAsplit  \
 LAcat  \
 LAshow  \
 LAdump  \
 LAcheck  \
 LAindex
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
