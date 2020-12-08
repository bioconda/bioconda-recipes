#!/bin/bash

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
cmake --build . --target Balrog -- -j 3
make install