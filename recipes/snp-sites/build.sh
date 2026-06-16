#!/bin/bash
set -xe

export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* m4/

autoreconf -if
./configure --prefix="$PREFIX"

make -j"${CPU_COUNT}"
make install
