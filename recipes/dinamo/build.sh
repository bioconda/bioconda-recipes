#!/bin/bash

mkdir -p "$PREFIX/bin"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CXX="${CXX}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 bin/dinamo "$PREFIX/bin"
