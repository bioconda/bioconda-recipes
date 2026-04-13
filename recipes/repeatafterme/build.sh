#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' util/*.pl
rm -rf util/*.bak
sed -i.bak 's|ar rcs|$(AR) rcs|' kentsrc/Makefile
sed -i.bak 's|cp RAMExtend $(INSTDIR)/bin|install -v -m 0755 RAMExtend $(INSTDIR)|' Makefile
sed -i.bak 's|-Iminunit -I.|-Iminunit -I. -Wno-format|' Makefile

make CC="${CC}" -j1

make install

install -v -m 0755 util/*.pl "${PREFIX}/bin"

cd kentsrc && make twoBitToFa CC="${CC}" -j1

install -v -m 0755 twoBitToFa "${PREFIX}/bin"
