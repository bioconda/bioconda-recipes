#! /bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
export CPATH=${PREFIX}/include
export CXXPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
echo "$LDFLAGS"
ls $PREFIX/lib/libdeflate*
cmake ..
make VERBOSE=1 mbgc
cp mbgc $PREFIX/bin
