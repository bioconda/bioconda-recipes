#!/bin/bash

git submodule init
git submodule update

export CXXFLAGS="-std=c++11"

make
mkdir -p $PREFIX/bin
cp _build/release/bin/sts-online $PREFIX/bin

