#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export CPATH=${PREFIX}/include

cmake -D CMAKE_INSTALL_PREFIX:PATH=$PREFIX .
make -j 2

cp regtools ${PREFIX}/bin
chmod +x ${PREFIX}/bin/regtools
