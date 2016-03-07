#!/bin/bash

mkdir -p $PREFIX/bin

#CFLAGS="-I. -I${PREFIX}/include -L${PREFIX}/lib" PREFIX=${PREFIX} make
make
cp nanopolish $PREFIX/bin
cp scripts/nanopolish_makerange.py $PREFIX/bin
cp scripts/nanopolish_merge.py $PREFIX/bin
cp scripts/consensus-preprocess.pl $PREFIX/bin

