#!/bin/bash
set -xe

# https://bioconda.github.io/troubleshooting.html#zlib-errors
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export CPPFLAGS="${CPPFLAGS} -I$PREFIX/include"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"

echo -e "5.3.0" > jemalloc/version.txt

autoreconf -if
./configure --prefix="${PREFIX}" \
  CC="${CC}" \
  CFLAGS="${CFLAGS}" \
  CXXFLAGS="${CXXFLAGS}" \
  CPPFLAGS="${CPPFLAGS}" \
  LDFLAGS="${LDFLAGS}"

sed -i.bak 's|$(HTSLIB_LIB)|-L$(PREFIX)/lib $(HTSLIB_LIB)|' Makefile
rm -f *.bak

make CC="${CC}" CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 longphase "$PREFIX/bin"
