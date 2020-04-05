#!/bin/sh

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/"
mkdir -p $PREFIX/bin
cp src/alfred $PREFIX/bin
