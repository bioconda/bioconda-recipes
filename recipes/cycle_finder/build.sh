#!/bin/bash

export CPPFLAGS="-I${PREFIX}/include"
export LDFLAGS="-L${PREFIX}/lib"
export CFLAGS="-g -Wall -O3 -std=c++0x -funroll-loops -I${PREFIX}/include -L${PREFIX}/lib -fopenmp"

mkdir -p "$PREFIX/bin"

make CC="${CXX}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 cycle_finder "$PREFIX/bin"
