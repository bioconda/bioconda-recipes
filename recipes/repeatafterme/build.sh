#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3"

mkdir -p "${PREFIX}/bin"
mkdir -p "${PREFIX}/bin/ram"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' util/*.pl
rm -f util/*.bak
sed -i.bak 's|ar rcs|$(AR) rcs|' c/kentsrc/Makefile
sed -i.bak 's|-Iminunit -I.|-Iminunit -I. -Wno-format|' c/Makefile
rm -f c/*.bak

cargo install --path ram-cli --root "${PREFIX}" --locked --no-track --verbose
# ram-cli's [[bin]] is "ram-extend", so this yields ${PREFIX}/bin/ram-extend

ln -sf "${PREFIX}/bin/ram-extend" "${PREFIX}/bin/RAMExtend"

install -v -m 0755 util/*.pl "${PREFIX}/bin/ram"

cd c/kentsrc && make twoBitToFa CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 twoBitToFa "${PREFIX}/bin"
