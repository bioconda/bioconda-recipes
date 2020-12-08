#!/bin/bash

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
cmake --build . --target Balrog -- -j 3
make install