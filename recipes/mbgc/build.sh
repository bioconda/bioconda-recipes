#! /bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
export CPATH=${BUILD_PREFIX}/include
export CXXPATH=${BUILD_PREFIX}/include
export CFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export CXXFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$BUILD_PREFIX/lib"
cp $BUILD_PREFIX/lib/libdeflate.h $BUILD_PREFIX/include/
cmake ..
make mbgc
cp mbgc $PREFIX/bin
