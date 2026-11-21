#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Ihtslib/htslib -Wno-implicit-function-declaration"

mkdir -p "${PREFIX}/bin"

sed -i.bak 's|-std=gnu99|-std=gnu11 -I$(PREFIX)/include -Wno-implicit-function-declaration|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|CLIB = -ltinfo|CLIB = -L$(PREFIX)/lib -ltinfo|' Makefile

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak 's/-ltinfo//g' Makefile
fi
rm -f *.bak

make CC="${CC}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 yame "${PREFIX}/bin"
