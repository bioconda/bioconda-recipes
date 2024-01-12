#! /bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
export CPATH=${BUILD_PREFIX}/include
export CXXPATH=${BUILD_PREFIX}/include
export CFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export CXXFLAGS="$CFLAGS -I$BUILD_PREFIX/include"
export LDFLAGS="$LDFLAGS -L$BUILD_PREFIX/lib"
cmake ..
if [[ "$(uname)" == "Linux" ]]; then
  make mbgc
else 
  make mbgc-noavx
  mv mbgc-noavx mbgc
fi
cp mbgc $PREFIX/bin
