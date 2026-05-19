#!/bin/bash

mkdir -p $PREFIX/bin
mkdir build
cd build
export CPATH=${PREFIX}/include
export CXXPATH=${PREFIX}/include
export CFLAGS="$CFLAGS -I$PREFIX/include"
export CXXFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
sed -i '/#include <fstream>/a #include <cstdint>' src/util.h
if [ $(arch) == "aarch64" ]; then
   cmake ..
  else
      cmake -Dspring_optimize_for_portability=ON ..
fi
make
cp spring $PREFIX/bin
