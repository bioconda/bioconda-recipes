#!/bin/sh
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../source
# Build the binary, this is required as a work-around to g++ not being found
ln -s ${CC} $BUILD_PREFIX/bin/gcc
ln -s ${CXX} $BUILD_PREFIX/bin/g++
export CXXFLAGS="$CXXFLAGS -L${PREFIX}/lib -L${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/lib"
export CPLUS_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/lib"
export CXX_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/lib"
export C_INCLUDE_PATH="${PREFIX}/include:${PREFIX}/lib"
export CPATH="${PREFIX}/include:${PREFIX}/lib"
export CFLAGS="-I${PREFIX}/include -I${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include:${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
make
cp ExpansionHunterDenovo $PREFIX/bin/ExpansionHunterDenovo
