#!/bin/sh

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
cp src/htslib/*.so* $PREFIX/lib
cp src/ocv/lib*/*.so* $PREFIX/lib
cp src/wally $PREFIX/bin
