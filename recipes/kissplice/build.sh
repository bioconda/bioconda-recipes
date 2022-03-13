#!/bin/bash

mkdir -p ${PREFIX}/bin

export CXXFLAGS="$CXXFLAGS -fcommon -I$PREFIX/include"
export CFLAGS="$CFLAGS -fcommon -I$PREFIX/include"

# Unfortunately this is not written to pass on appropriate flags
sed -i.bak "s#fopenmp#fopenmp -I$PREFIX/include#g" CMakeLists.txt
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_LIBRARY_PATH=$PREFIX/lib $DCMAKE_INCLUDE_PATH=$PREFIX/include .

# make commands
make -j1 VERBOSE=1
make install
