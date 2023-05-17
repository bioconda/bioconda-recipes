#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include -I${BUILD_PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I${BUILD_PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
fi

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

autoconf
autoheader
./configure CC=${CC} --prefix="${PREFIX}" --with-simd-level=sse42
make CC=${CC} CFLAGS="${CFLAGS} ${LDFLAGS}" CPPFLAGS="${CPPFLAGS} ${LDFLAGS}" -j 4
make install
make clean
