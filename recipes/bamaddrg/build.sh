#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include/"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

mkdir -p build
cd build
CMAKE_FLAGS="-DZLIB_ROOT=$PREFIX"


sed -i.bak "s#g++#$CXX#g" Makefile
sed -i.bak2 "s#cmake#cmake $CMAKE_FLAGS#g" Makefile

make CXX=${CXX} 
