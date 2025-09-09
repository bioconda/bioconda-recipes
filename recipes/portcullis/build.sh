#!/bin/bash
set -x -e

export CFLAGS="-I$PREFIX/include $CFLAGS -O3"
export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export CXXFLAGS="-I$PREFIX/include $CXXFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LIBS="-lm ${PREFIX}/lib/libz.a"

./autogen.sh
./configure --enable-silent-rules \
	--disable-dependency-tracking \
	--prefix="${PREFIX}" \
	--with-boost="${PREFIX}" \
	--with-boost-libdir="${PREFIX}/lib"

make -j"${CPU_COUNT}"
make -j"${CPU_COUNT}" check

make install
