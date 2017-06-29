#!/bin/bash

mkdir -p $PREFIX/bin
make

binaries="\
 dextract  \
 dexta  \
 undexta  \
 dexqv  \
 undexqv  
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done
