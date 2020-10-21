#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH=${PREFIX}/include

mkdir build
cd build
cmake -D CMAKE_INSTALL_PREFIX:PATH=${PREFIX} -D CMAKE_INSTALL_RPATH:STRING=${PREFIX}/lib ..
make -j 4

mkdir -p ${PREFIX}/bin
cp regtools ${PREFIX}/bin
chmod +x ${PREFIX}/bin/regtools
