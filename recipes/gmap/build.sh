#!/bin/sh

patch -p1 < ${RECIPE_DIR}/single_quote_paths.patch

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

autoheader
autoconf
./configure --prefix=${PREFIX} --with-simd-level=sse42
make CC=${CC} CPPFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}" CFLAGS="-I${PREFIX}/include -I${BUILD_PREFIX}/include ${LDFLAGS}" -j 2
make install
