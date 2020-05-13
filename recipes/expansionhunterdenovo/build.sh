#!/bin/sh
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release ../source
# Build the binary, this is required as a work-around to g++ not being found
ln -s ${CC} $BUILD_PREFIX/bin/gcc
ln -s ${CXX} $BUILD_PREFIX/bin/g++
export CPLUS_INCLUDE_PATH=$PREFIX/include
make
cp ExpansionHunterDenovo $PREFIX/bin/ExpansionHunterDenovo
