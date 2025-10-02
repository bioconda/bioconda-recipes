#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak 's|-g -O2 $(CFLAGS0)|-g -O3 $(CFLAGS0) -Xlinker -zmuldefs -Wno-implicit-int -Wno-implicit-function-declaration|' Makefile

if [[ "$(uname -s)" == "Darwin" ]]; then
  sed -i.bak 's|-zmuldefs||' Makefile
fi

rm -rf *.bak

make CC="${CC}" -j"${CPU_COUNT}"
# copy binary to prefix folder
install -v -m 0755 bin/domclust Script/*.pl build_input/*.pl "${PREFIX}/bin"

# test
bin/domclust -h
bin/domclust tst/test.hom tst/test.gene
