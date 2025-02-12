#!/bin/bash

export CPATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -fcommon"
if [ "$(uname)" = "Darwin" ]; then
    export CFLAGS="${CFLAGS} -fcommon -std=c89"
fi
./bootstrap
./configure --prefix=${PREFIX}
make
make install
