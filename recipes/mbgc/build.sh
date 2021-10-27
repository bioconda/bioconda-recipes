#! /bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
echo "$LDFLAGS"
ls $BUILD_PREFIX/lib/libdeflate*
cmake ..
make VERBOSE=1 mbgc
cp mbgc $PREFIX/bin
