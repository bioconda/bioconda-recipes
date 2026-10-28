#!/bin/sh

export BOOST_ROOT="${PREFIX}"
export CXXFLAGS="${CXXFLAGS} -std=c++11"

mkdir build
cd build
../src/configure --prefix=${PREFIX} --build-type=Release
make
make install
