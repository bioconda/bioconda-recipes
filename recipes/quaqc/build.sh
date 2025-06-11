#!/bin/bash

set -ex

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/share/man/man1"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-std=gnu99|-std=gnu11|' Makefile
rm -rf *.bak

make CC="${CC}" CFLAGS="${CFLAGS}" PREFIX="${PREFIX}" z_dyn=1 hts_dyn=1 release -j"${CPU_COUNT}"
make install
