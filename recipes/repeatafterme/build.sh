#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

mkdir -p "${PREFIX}/bin"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' util/*.pl
rm -rf util/*.bak

make CC="${CC}" -j"${CPU_COUNT}"

make install

install -v -m 0755 util/*.pl "${PREFIX}/bin"

cd kentsrc && make twoBitToFa CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 twoBitToFa "${PREFIX}/bin"
