#!/bin/sh

export CXXFLAGS="${CXXFLAGS} -std=c++14"
export CPPFLAGS="${CPPFLAGS} -std=c++14"
export CFLAGS="$CFLAGS -std=c++14"

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include -L${SRC_DIR}/src/sdslLite/lib -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/ -std=c++14"
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
