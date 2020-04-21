#!/bin/bash

mkdir -p $PREFIX/bin
sed -i.bak 's|\bgcc\b|\${CC}|g' Makefile # use platform-specific compiler
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
 LAa2b  \
 LAb2a  \
 dumpLA
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
