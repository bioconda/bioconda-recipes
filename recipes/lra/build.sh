#!/bin/bash

mkdir -p "$PREFIX/bin"

export CFLAGS="$CFLAGS -O3"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CFLAGS="$CFLAGS -O3"
export CXXFLAGS="$CXXFLAGS -O3"

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"  CXX="${CXX} ${CXXFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 lra "$PREFIX/bin"
