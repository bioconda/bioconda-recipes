#!/bin/sh

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="$-L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include -I${BUILD_PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -I${BUILD_PREFIX}/include"

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

./configure CC="${CC}" --prefix="${PREFIX}" --with-simd-level=sse42
make CC="${CC}" CFLAGS="${CFLAGS}" CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" -j 4
make install
make clean
