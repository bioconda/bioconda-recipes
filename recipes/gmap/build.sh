#!/bin/sh

export C_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"
export CFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}"

./configure --prefix=${PREFIX} CFLAGS="${CFLAGS}" --with-simd-level=sse42
make CC=${CC} CFLAGS="${CFLAGS}" -j 2
make install prefix=${PREFIX}
