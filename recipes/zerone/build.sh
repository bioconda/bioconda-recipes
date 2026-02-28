#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-function-declaration"

mkdir -p "${PREFIX}/bin"

if [[ "${target_platform}" == "linux-aarch64" || "${target_platform}" == "osx-arm64" ]]; then
	sed -i.bak '19s/#include <emmintrin.h>/\/\//' src/zinm.h
	rm -f src/*.bak
fi

make CC="${CC} ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 zerone "${PREFIX}/bin"
