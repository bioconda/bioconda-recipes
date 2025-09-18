#!/bin/bash
set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -std=c++14"

# cd to location of Makefile and source
cd gnuac

cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .

# depends on automake, autoconf
autoreconf -if
./configure --prefix="$PREFIX" \
  CFLAGS="${CFLAGS}" \
  CC="${CC}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}"

make -j"${CPU_COUNT}"
make install
