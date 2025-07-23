#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"

sed -i.bak 's|-march=native|-msse4.2 -mpopcnt|' Makefile

make CC="${CC}" -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"
