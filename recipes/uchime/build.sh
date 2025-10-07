#!/bin/bash

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include -Wno-format-overflow"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CXXFLAGS="${CXXFLAGS} -O3"

mkdir -p "${PREFIX}/bin"

case $(uname -m) in
	aarch64|arm64) sed -i.bak 's|-msse2 -mfpmath=sse||' mk && rm -rf *.bak ;;
esac

make CXX="${CXX}" -j"${CPU_COUNT}"

install -v -m 0755 uchime "${PREFIX}/bin"
