#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' perl/*.pl
rm -rf perl/*.bak
install -v -m 0755 perl/*.pl "${PREFIX}/bin"
sed -i.bak 's|-O2|-O3|' src/Makefile.in
rm -rf src/*.bak

cd src

CXX="${CXX}" ./configure --exec_prefix="${PREFIX}/bin" \
	--table_dir="${PREFIX}/share/spaln/table" --alndbs_dir="${PREFIX}/share/spaln/alndbs"

sed -i.bak 's|-lpthread|-pthread|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile
rm -rf *.bak

make CFLAGS="${CFLAGS} -O3" AR="${AR:-ar} rcs" LDFLAGS="${LDFLAGS}" -j"${CPU_COUNT}"
make install

make clearall
