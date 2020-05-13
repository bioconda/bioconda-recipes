#!/bin/sh
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../source
# Build the binary, this is required as a work-around to g++ not being found
ln -s ${CC} $BUILD_PREFIX/bin/gcc
ln -s ${CXX} $BUILD_PREFIX/bin/g++
export CXXFLAGS="$CXXFLAGS -L${PREFIX}/lib"
export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
make
cp ExpansionHunterDenovo $PREFIX/bin/ExpansionHunterDenovo
