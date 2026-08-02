#!/bin/bash

export CFLAGS="${CFLAGS} -O3"
export LDFLAGS="${LDFLAGS} -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -std=c++14"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

pushd $SRC_DIR/src

mkdir -p build-aux
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* .
cp -f ${BUILD_PREFIX}/share/gnuconfig/config.* build-aux/

autoreconf -if
./configure --prefix="$PREFIX" --with-bamtools="$PREFIX" --with-sparsehash="$PREFIX" \
	CC="${CC}" CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" CXX="${CXX}" \
	CPPFLAGS="${CPPFLAGS}" LDFLAGS="${LDFLAGS}"

make
make install
