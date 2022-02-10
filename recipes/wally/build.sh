#!/bin/sh

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib"
mkdir -p $PREFIX/bin
cp src/wally $PREFIX/bin
