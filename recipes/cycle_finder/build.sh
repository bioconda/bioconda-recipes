#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CXXFLAGS} -O3 -std=c++0x -I${PREFIX}/include -fopenmp -funroll-loops -g -Wall"

mkdir -p "$PREFIX/bin"

make CC="${CXX}" CFLAGS="${CFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 cycle_finder "$PREFIX/bin"
