#!/usr/bin/env bash

export CFLAGS="${CFLAGS//-march=nocona/}"
export CFLAGS="${CFLAGS//-mtune=haswell/}"
export CXXFLAGS="${CXXFLAGS//-march=nocona/}"
export CXXFLAGS="${CXXFLAGS//-mtune=haswell/}"

mkdir -p $PREFIX/bin

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release \
         -DNATIVE=OFF \
         -DCONDA_BUILD=ON \
         -DWITH_MODULES=ON

make -j 8 && make test

cp mogs $PREFIX/bin

