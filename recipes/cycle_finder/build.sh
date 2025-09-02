#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="-g -Wall -O3 -std=c++0x -I${PREFIX}/include -L${PREFIX}/lib -fopenmp -funroll-loops"

mkdir -p "$PREFIX/bin"

make CC="${CXX}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 cycle_finder "$PREFIX/bin"
