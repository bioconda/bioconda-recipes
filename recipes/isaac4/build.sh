#!/bin/sh

export BOOST_ROOT="${PREFIX}"
export CXXFLAGS="-std=c++11"

mkdir build
cd build
../src/configure --prefix=${PREFIX}
make
make install
