#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include:"${PREFIX}/include/ncurses"
export LIBRARY_PATH="${PREFIX}/lib"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig"

sed -i.bak 's|-lpthread|-pthread|' Makefile
rm -f *.bak

make all -j"${CPU_COUNT}"

for i in *.x; do
	install -v -m 0755 ${i} "${PREFIX}/bin"
done
