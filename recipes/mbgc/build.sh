#! /bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
export CPATH=${BUILD_PREFIX}/include
export CXXPATH=${BUILD_PREFIX}/include
export CFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export CXXFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$BUILD_PREFIX/lib"
echo "$LDFLAGS"
ls $BUILD_PREFIX/lib/libdeflate*
cmake ..
make VERBOSE=1 mbgc
cp mbgc $PREFIX/bin
