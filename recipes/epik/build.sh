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

cmake -B build -DBUILD_SHARED_LIBS=ON --install-prefix=$PREFIX
cmake --build build --target all -j ${CPU_COUNT}
cmake --install build

ls $PREFIX/bin
ls $PREFIX/lib

chmod +x $PREFIX/bin/epik-aa
chmod +x $PREFIX/bin/epik-dna
chmod +x $PREFIX/bin/epik.py
