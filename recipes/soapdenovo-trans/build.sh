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

sed -i.bak 's|1.04|1.0.5|' src/main.c
sed -i.bak 's|1.04|1.0.5|' VERSION
rm -rf src/*.bak
rm -rf *.bak

pushd src
make 127mer=1 CC="${CC}" -j"${CPU_COUNT}"
make CC="${CC}" clean
make 63mer=1 CC="${CC}" -j"${CPU_COUNT}"
make CC="${CC}" clean
make CC="${CC}" -j"${CPU_COUNT}"
popd

"${STRIP}" SOAPdenovo-Trans-*mer

install -v -m 0755 SOAPdenovo-Trans-*mer "${PREFIX}/bin"
