#!/bin/bash

mkdir -p "${PREFIX}/bin"

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 ${LDFLAGS}"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' ${SRC_DIR}/perl/*.pl
rm -rf ${SRC_DIR}/perl/*.bak
cp -rf ${SRC_DIR}/perl/*.pl "${PREFIX}/bin"

cd src

./configure --exec_prefix="${PREFIX}/bin" --table_dir="${PREFIX}/share/spaln/table" \
	--alndbs_dir="${PREFIX}/share/spaln/alndbs"

make CFLAGS="${CFLAGS}" AR="${AR:-ar} rc" LDFLAGS="${LDFLAGS}" -j4
make install

make clearall
