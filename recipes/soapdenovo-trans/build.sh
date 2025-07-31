#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3"

install -d "${PREFIX}/bin"

if [[ `uname -s` == "Darwin" ]]; then
	sed -i.bak 's|-static||' src/Makefile
	sed -i.bak 's|-lrt||' src/Makefile
fi

sed -i.bak 's|1.04|1.05|' src/main.c
sed -i.bak 's|1.04|1.05|' VERSION
rm -rf src/*.bak
rm -rf *.bak

pushd src
make CC="${CC} -fcommon" LIBPATH="${LDFLAGS}" -j"${CPU_COUNT}"
make 63mer=1 CC="${CC} -fcommon" LIBPATH="${LDFLAGS}" -j"${CPU_COUNT}"
make 127mer=1 CC="${CC} -fcommon" LIBPATH="${LDFLAGS}" -j"${CPU_COUNT}"
popd

"${STRIP}" SOAPdenovo-Trans-*

install -v -m 0755 SOAPdenovo-Trans-* "${PREFIX}/bin"
