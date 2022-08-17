#!/bin/bash

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CPATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include

# cd to location of Makefile and source
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX}/bin -DCMAKE_BUILD_TYPE=Release ..
make
make install
