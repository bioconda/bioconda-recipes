#!/bin/bash

mkdir -p ${PREFIX}/bin

export CXXFLAGS="$CXXFLAGS -fcommon -I$PREFIX/include"
export CFLAGS="$CFLAGS -fcommon -I$PREFIX/include"
# cmake command
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_LIBRARY_PATH=$PREFIX/lib $DCMAKE_INCLUDE_PATH=$PREFIX/include .

# make commands
make -j1 VERBOSE=1
make install
