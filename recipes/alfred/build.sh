#!/bin/sh

export CXXFLAGS="${CXXFLAGS} -std=c++11"
export CPPFLAGS="${CPPFLAGS} -std=c++11"
make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/"
mkdir -p $PREFIX/bin
cp src/alfred $PREFIX/bin
