#!/bin/bash

mkdir -p $PREFIX/bin
sed -i.bak 's|\bgcc\b|\${CC}|g' Makefile # use platform-specific compiler
make

binaries="\
 daligner  \
 HPC.daligner  \
 LA2ONE  \
 LAcat  \
 LAcheck  \
 LAmerge  \
 LAshow  \
 LAsort  \
 LAsplit  \
 ONE2LA  
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
