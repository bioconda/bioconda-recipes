#!/bin/bash

mkdir -p ${PREFIX}/bin

mkdir -p build
cd build

export CXXFLAGS="$CXXFLAGS -fcommon -I$PREFIX/include"
export CFLAGS="$CFLAGS -fcommon -I$PREFIX/include"
# cmake command
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_C_FLAGS="$CFLAGS" ..

# make commands
make -j1 VERBOSE=1
make test
make install
