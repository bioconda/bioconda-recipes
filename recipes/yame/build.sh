#!/bin/bash

export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -Ihtslib/htslib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak 's/-ltinfo//g' Makefile
fi

sed -i.bak 's|-std=gnu99|-std=c11 -I$(PREFIX)/include|' Makefile
sed -i.bak 's|-lpthread|-pthread|' Makefile
rm -rf *.bak

make CC="${CC}" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"

install -v -m 0755 yame "${PREFIX}/bin"
