#!/bin/bash

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "$PREFIX/bin"

make CC="$CXX" -j"${CPU_COUNT}"

install -v -m 0755 cycle_finder "$PREFIX/bin"
