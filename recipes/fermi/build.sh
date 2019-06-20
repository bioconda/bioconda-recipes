#!/bin/bash
export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

mkdir -p $PREFIX/bin
sed -i.bak "s/inline void ld_set/static inline void ld_set/g" bcr.c

make CC=$CC
mv fermi  $PREFIX/bin
mv run-fermi.pl $PREFIX/bin
