#!/bin/bash

# flags for building libBigWig dependency
# export C_INCLUDE_PATH=${PREFIX}/include
# export LIBRARY_PATH=${PREFIX}/lib
# export LD_LIBRARY_PATH=${PREFIX}/lib
#
# CFLAGS="$CFLAGS -g -Wall -O3 -Wsign-compare -L$PREFIX/lib -I$PREFIX/include"
# LIBS="$LDFLAGS -L$PREFIX/lib -lm -lz"

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release -DPHYLOCSFPP_BUILD_LIBBIGWIG=OFF
make
make install
