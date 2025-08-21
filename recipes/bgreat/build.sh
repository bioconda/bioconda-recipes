#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
export CPATH="${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make zobu="${LDFLAGS}" CC="${CXX}" CFLAGS="${CXXFLAGS} -flto -funit-at-a-time -fopenmp -lz" -j"${CPU_COUNT}"

install -v -m 0755 bgreat "$PREFIX/bin"
