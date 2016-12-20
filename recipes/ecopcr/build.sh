#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

mkdir -p $PREFIX/bin

cd src
make

binaries="\
ecoPCR \
ecofind \
ecogrep \
"

for i in $binaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

cd ../tools

pybinaries="\
ecoPCRFilter.py \
ecoPCRFormat.py \
ecoSort.py \
"
for i in $pybinaries; do cp $i $PREFIX/bin && chmod +x $PREFIX/bin/$i; done

