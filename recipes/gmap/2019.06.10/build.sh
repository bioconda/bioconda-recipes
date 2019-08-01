#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"

./configure --prefix=${PREFIX} --with-simd-level=sse42
make -j 2
make install prefix=${PREFIX}
