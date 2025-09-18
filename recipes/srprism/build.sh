#!/bin/bash
set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3 -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

# cd to location of Makefile and source
cd gnuac

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

# depends on automake, autoconf
autoreconf -if
./configure --prefix="$PREFIX"

make -j"${CPU_COUNT}"
make install
