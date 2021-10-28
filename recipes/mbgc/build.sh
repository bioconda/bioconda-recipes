#! /bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
echo "$LDFLAGS"
ls $BUILD_PREFIX/lib/libdeflate*
cp $BUILD_PREFIX/lib/libdeflate.h $BUILD_PREFIX/include/
cp $BUILD_PREFIX/lib/libdeflate.h $PREFIX/include/
cmake ..
make VERBOSE=1 mbgc
cp mbgc $PREFIX/bin
