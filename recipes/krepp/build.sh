#!/bin/bash
set -xe

export CXXFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"

make -j ${CPU_COUNT} COMPILER=$CXX
chmod 0755 krepp

mkdir -p $PREFIX/bin
cp krepp $PREFIX/bin
