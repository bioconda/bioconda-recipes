#!/bin/sh

export INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if test x"`uname`" = x"Linux"; then
    LDFLAGS="${LDFLAGS} -Wl,-as-needed,${PREFIX}/lib"
fi

if [ "$(uname)" == "Darwin" ]; then
    # for Mac OSX
    export LDFLAGS="${LDFLAGS} -headerpad_max_install_names -Wl,-rpath,${PREFIX}/lib"
    export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
else
    export CPP_FOR_BUILD=${CPP}
fi

export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

autoconf
autoheader
./configure CC=${CC} --prefix=${PREFIX} --with-simd-level=sse42
make CC=${CC} CXX=${CXX} CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include ${LDFLAGS}" CFLAGS="${CFLAGS} -I${PREFIX}/include ${LDFLAGS}" -j 4
make install
make clean
