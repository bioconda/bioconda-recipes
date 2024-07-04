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
cmake --build build --target all --target diff-dna --target diff-aa --target dump-dna --target dump-aa
cmake --install $PREFIX

ls $PREFIX/*

#cp build/ipk/ipk-aa $PREFIX/bin
#cp build/ipk/ipk-aa-pos $PREFIX/bin
#cp build/ipk/ipk-dna $PREFIX/bin
#cp build/tools/diff-dna $PREFIX/bin
#cp build/tools/diff-aa $PREFIX/bin
#cp build/tools/dump-dna $PREFIX/bin
#cp build/tools/dump-aa $PREFIX/bin

#cp build/i2l/libi2l_aa.a $PREFIX/lib
#cp build/i2l/libi2l_aa_pos.a $PREFIX/lib
#cp build/i2l/libi2l_dna.a $PREFIX/lib

#chmod +x $PREFIX/bin/ipk-aa
#chmod +x $PREFIX/bin/ipk-dna
#chmod +x $PREFIX/bin/ipk-aa-pos
#chmod +x $PREFIX/bin/ipk.py
