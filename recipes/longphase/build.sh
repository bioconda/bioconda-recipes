#!/bin/bash
set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"

autoreconf -if
./configure --prefix="${PREFIX}" \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}"

sed -i.bak 's|$(HTSLIB_LIB)|-L$(PREFIX)/lib $(HTSLIB_LIB)|' Makefile
rm -f *.bak

make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 longphase "$PREFIX/bin"
