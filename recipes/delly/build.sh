#!/bin/sh

make all CXX=$CXX CXXFLAGS="-I${PREFIX}/include -L${PREFIX}/lib"
mkdir -p $PREFIX/bin
cp src/delly $PREFIX/bin
