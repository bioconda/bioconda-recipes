#!/bin/bash

mkdir -p $PREFIX/bin

export CFLAGS="-I$PREFIX/include -fgnu89-inline -O2 -D USE_JEMALLOC  -w -lrt -lz"
export LIBS="-pthread -lm ${PREFIX}/lib/libz.* -lm ${PREFIX}/lib/libjemalloc.* -lm ${PREFIX}/lib/libhdf5.*  -lm ${PREFIX}/lib/libhdf5_hl.* -ldl -lm ${PREFIX}/lib/libdivsufsort64.*"

./configure

make
cp build/hera $PREFIX/bin
cp build/hera_build $PREFIX/bin
