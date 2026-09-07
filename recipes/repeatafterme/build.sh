#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' util/*.pl
rm -f util/*.bak
sed -i.bak 's|ar rcs|$(AR) rcs|' c/kentsrc/Makefile
#sed -i.bak 's|cp RAMExtend $(INSTDIR)/bin|install -v -m 0755 RAMExtend $(INSTDIR)|' c/Makefile
sed -i.bak 's|-Iminunit -I.|-Iminunit -I. -Wno-format|' c/Makefile

sed -i.bak 's|0.1.0|0.2.0|' Makefile
sed -i.bak "s|/usr/local/RepeatAfterMe-$(VERSION)|$(PREFIX)/bin|" Makefile
rm -f *.bak

make CC="${CC}" -j"${CPU_COUNT}"

make install

install -v -m 0755 util/*.pl "${PREFIX}/bin"

cd c/kentsrc && make twoBitToFa CC="${CC}" -j"${CPU_COUNT}"

install -v -m 0755 twoBitToFa "${PREFIX}/bin"
