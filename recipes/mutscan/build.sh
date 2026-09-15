#!/bin/bash
set -eu -o pipefail

mkdir -p "${PREFIX}/bin"

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ ${OSTYPE} == "darwin"* ]]; then
	LDFLAGS="${LDFLAGS} -lc"
fi

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile && rm -rf *.bak
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile && rm -rf *.bak
	;;
esac

make LDFLAGS="${LDFLAGS}" DIR_INC="${PREFIX}/include" CC="${CXX}" -j"${CPU_COUNT}"

make install BINDIR="${PREFIX}/bin"
