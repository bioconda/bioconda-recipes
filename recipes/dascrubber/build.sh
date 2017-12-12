#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
 DASqv  \
 DAStrim \
 DASpatch \
 DASedit \
 DASmap \
 DASrealign \
 REPqv \
 REPqv
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
