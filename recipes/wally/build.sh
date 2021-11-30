#!/bin/sh

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${PREFIX}/include -L${PREFIX}/lib"
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/lib
find ${BUILD_PREFIX}/ -iname "*libGL*" -exec cp -- "{}" $PREFIX/lib/ \;
cp src/wally $PREFIX/bin
