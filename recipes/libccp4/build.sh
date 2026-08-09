#!/bin/bash
set -exo pipefail

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/
sed -i.bak 's/int putenv ();/extern int putenv (char *);/' ccp4/library_utils.c
rm -rf ccp4/*.bak

autoreconf -if
./configure \
    --prefix="${PREFIX}" \
    --enable-shared \
    --enable-fortran \
    --disable-static \
    --disable-debug \
    --disable-dependency-tracking \
    --enable-silent-rules \
    --disable-option-checking \
    CC="${CC}" CFLAGS="${CFLAGS}" \
    CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}" \
    CXX="${CXX}" CXXFLAGS="${CXXFLAGS}"

make -j"${CPU_COUNT}"
make install
