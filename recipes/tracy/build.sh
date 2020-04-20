#!/bin/sh

export CXXFLAGS="${CXXFLAGS} -std=c++14"
export CPPFLAGS="${CPPFLAGS} -std=c++14"
export CFLAGS="$CFLAGS -std=c++14"

if [ "$(uname)" == "Darwin" ]
then
    export CXX_FLAGS="${CXX_FLAGS} -std=c++14"
    export CMAKE_CXX_FLAGS="${CMAKE_CXX_FLAGS} -std=c++14"
    export CMAKE_C_COMPILER="clang"
    export CMAKE_CXX_COMPILER="clang++"
    export CXX=clang++
    export CC=clang
fi

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include -L${SRC_DIR}/src/sdslLite/lib -I${PREFIX}/include -L${PREFIX}/lib -Isrc/jlib/ -std=c++14"
mkdir -p $PREFIX/bin
cp src/tracy $PREFIX/bin
