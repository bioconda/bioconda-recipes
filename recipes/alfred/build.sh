#!/bin/sh

make all CXX=$CXX CMDCXXFLAGS="-I${PREFIX}/include" CMDLDFLAGS="-L$PREFIX/lib"
mkdir -p $PREFIX/bin
cp src/alfred $PREFIX/bin
