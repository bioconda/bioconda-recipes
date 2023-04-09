#!/bin/sh

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"

autoheader
autoreconf
./configure --prefix=${PREFIX} --with-simd-level=avx2
make CC=${CC} CPPFLAGS="-I${PREFIX}/include ${LDFLAGS}" CFLAGS="-I${PREFIX}/include ${LDFLAGS}" -j 2
make install
