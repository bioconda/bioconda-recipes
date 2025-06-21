#!/bin/bash
set -xeuo pipefail

export C_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
	sed -i.bak 's|-std=c++14||' Makefile
	rm -rf *.bak
fi

case $(uname -m) in
    aarch64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8-a|' Makefile
	;;
    arm64)
	sed -i.bak 's|-march=x86-64-v3|-march=armv8.4-a|' Makefile
	;;
esac


make CC="${CC} -fcommon" CXX="${CXX} -fcommon" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 755 ema "${PREFIX}/bin"
