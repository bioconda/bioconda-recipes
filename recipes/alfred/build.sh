#!/bin/sh

if [ "$(uname)" == "Darwin" ]
then
    CXXFLAGS="$CXXFLAGS";
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
    export CXX_FLAGS="${CXX_FLAGS} -stdlib=libc++ -std=c++11 -I${PREFIX}/include"
    export C_INCLUDE_PATH=${PREFIX}/include
    export CPLUS_INCLUDE_PATH=${PREFIX}/include
    export BOOST_ROOT=${PREFIX}
    export CXX=clang++
    export CC=clang
fi

make all CXX=$CXX CXXFLAGS="-D__STDC_FORMAT_MACROS -I${SRC_DIR}/src/sdslLite/include -L${SRC_DIR}/src/sdslLite/lib -I${PREFIX}/include -L${PREFIX}/lib"
mkdir -p $PREFIX/bin
cp src/alfred $PREFIX/bin
