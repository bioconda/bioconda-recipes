#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

#to ensure zlib location
export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cmake -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" 
cmake --build . --target all

cp ipk/ipk-aa $PREFIX/bin
cp ipk/ipk-aa-pos $PREFIX/bin
cp ipk/ipk-dna $PREFIX/bin
cp ipk.py $PREFIX/bin

chmod +x $PREFIX/bin/ipk-aa
chmod +x $PREFIX/bin/ipk-dna
chmod +x $PREFIX/bin/ipk-aa-pos
chmod +x $PREFIX/bin/ipk.py
