#!/bin/bash

set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

autoreconf -ifv
./configure \
    --prefix="${PREFIX}" \
    --enable-shared \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-silent-rules \
    --disable-option-checking \
    CC="${CC}" \
    CXX="${CXX}" \
    CFLAGS="${CFLAGS}" \
    CXXFLAGS="${CXXFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" \
    LDFLAGS="${LDFLAGS}" \

make -j"${CPU_COUNT}"
make install
