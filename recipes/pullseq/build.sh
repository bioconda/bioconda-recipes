#!/bin/bash

export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LD_FLAGS="-L${PREFIX}/lib"

./bootstrap
./configure --prefix=${PREFIX}
make
make install
