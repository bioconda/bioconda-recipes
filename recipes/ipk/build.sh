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

cmake -B build -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" -DBUILD_SHARED_LIBS=ON --install-prefix=$PREFIX
cmake --build build --target all
cmake --install build

ls build/ipk

cp build/ipk/ipk-aa $PREFIX/bin
cp build/ipk/ipk-aa-pos $PREFIX/bin
cp build/ipk/ipk-dna $PREFIX/bin

chmod +x $PREFIX/bin/ipk-aa
chmod +x $PREFIX/bin/ipk-dna
chmod +x $PREFIX/bin/ipk-aa-pos
chmod +x $PREFIX/bin/ipk.py
