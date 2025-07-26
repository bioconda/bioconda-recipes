#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPATH="${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
  aarch64|arm64) sed -i.bak 's|-march=native|-march=armv8-a|' Makefile && make universal CC="${CC}" -j"${CPU_COUNT}" ;;
  *) sed -i.bak 's|-march=native|-msse4.2 -mpopcnt|' Makefile && make CC="${CC}" -j"${CPU_COUNT}" ;;
esac

make install CC="${CC}" PREFIX="${PREFIX}"
