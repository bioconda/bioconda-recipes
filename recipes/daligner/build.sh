#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
  daligner \
  HPCdaligner \
  HPCmapper \
  LAsort \
  LAmerge \
  LAsplit \
  LAcat \
  LAshow \
  LAcheck \
  "

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
