#!/bin/bash

export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -fcommon"

./bootstrap
./configure --prefix=${PREFIX}
make
make install
