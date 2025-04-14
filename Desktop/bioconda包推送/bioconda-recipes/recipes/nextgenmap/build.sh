#!/bin/bash

mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_EXE_LINKER_FLAGS=-L${PREFIX}/lib ..
make

mkdir -p $PREFIX/bin
cp -r ../bin/ngm-${PKG_VERSION}/* $PREFIX/bin/
