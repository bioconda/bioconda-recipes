#!/bin/sh

export INCLUDE_PATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"

autoheader
autoconf
./configure --prefix=${PREFIX} --with-simd-level=sse42
make CC=${CC} CFLAGS="-I${PREFIX}/include ${LDFLAGS}" -j 2
make install
