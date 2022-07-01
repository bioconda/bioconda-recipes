#!/bin/bash

# Ensure we run successfully using either conda-forge or defaults ncurses
# (unlike other platforms, the latter does not automatically pull in libtinfo)

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
# export CPATH=${BUILD_PREFIX}/bin
export PKG_CONFIG_EXECUTABLE=${BUILD_PREFIX}/bin/pkg-config

which pkg-config
which cmake
echo "$CPATH"

sed -i '25 i set(PKG_CONFIG_EXECUTABLE ${PKG_CONFIG_EXECUTABLE})' src/CMakeLists.txt

mkdir build
cd build

cmake -DBUILD_SHARED_LIBS:BOOL=ON -DCMAKE_INSTALL_PREFIX:PATH=${PREFIX} ../src

make CC="${CC}" CXX="${CXX}" LDFLAGS="${LDFLAGS}" -lhts -lboost_iostreams
