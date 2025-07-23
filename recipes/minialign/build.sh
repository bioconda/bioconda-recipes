#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

mkdir -p "$PREFIX/bin"

case $(uname -m) in
  aarch64|arm64) sed -i.bak 's|-march=native||' Makefile && rm -rf *.bak ;;
  *) sed -i.bak 's|-march=native|-msse4.2 -mpopcnt|' Makefile && rm -rf *.bak ;;
esac

make CC="${CC}" -j"${CPU_COUNT}"

make install PREFIX="${PREFIX}"
