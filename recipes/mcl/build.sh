#!/bin/bash

mkdir -p $PREFIX/bin

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CFLAGS="${CFLAGS} -O3 -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cd cimfomfa
./configure --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--enable-shared
make -j"${CPU_COUNT}"
make install
make clean

cd ..
./configure --prefix="${PREFIX}" \
	CC="${CC}" CFLAGS="${CFLAGS}" \
	CPPFLAGS="${CPPFLAGS}" \
	LDFLAGS="${LDFLAGS}" \
	--enable-rcl
make -j"${CPU_COUNT}"
make install
make clean
