#!/bin/bash

git submodule init
git submodule update

export CXXFLAGS="-std=c++11"
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin
