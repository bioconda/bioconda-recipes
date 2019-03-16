#!/bin/bash

git submodule init
git submodule update

export CXXFLAGS="-std=c++11"
export INCLUDE_PATH=${PREFIX}/include
export GSL_INCLUDE_DIRS=${PREFIX}/include

make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin

