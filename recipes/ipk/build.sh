#!/bin/bash
set -ex

export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include

#to ensure zlib location
export CFLAGS="$CFLAGS -O3 -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib

cmake -B build -DHASH_MAP=USE_TSL_ROBIN_MAP -DCMAKE_CXX_FLAGS="-O3" -DBUILD_SHARED_LIBS=ON --install-prefix="$PREFIX"
cmake --build build --target all --target diff-dna --target diff-aa --target dump-dna --target dump-aa -j "${CPU_COUNT}"
cmake --install build

install -v -m 0755 build/ipk/ipk-aa \
	build/ipk/ipk-aa-pos \
	build/ipk/ipk-dna \
	build/tools/ipkdiff-dna \
	build/tools/ipkdiff-aa \
	build/tools/ipkdump-dna \
	build/tools/ipkdump-aa "$PREFIX/bin"

cp -f build/i2l/libi2l_aa.a $PREFIX/lib
cp -f build/i2l/libi2l_aa_pos.a $PREFIX/lib
cp -f build/i2l/libi2l_dna.a $PREFIX/lib
