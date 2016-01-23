#!/bin/bash

# cd to location of Makefile and source
cd $SRC_DIR

make

binaries="\
combineMUMs \
delta-filter \
dnadiff \
exact-tandems \
mapview \
mgaps \
mummer \
mummerplot \
nucmer \
promer \
repeat-match \
run-mummer1 \
run-mummer3 \
show-coords \
show-diff \
show-snps \
show-tiling \
"

mkdir -p $PREFIX/bin
for i in $binaries; do cp $SRC_DIR/$i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done