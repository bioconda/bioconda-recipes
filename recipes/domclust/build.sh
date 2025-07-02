#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -Wno-implicit-int -Wno-implicit-function-declaration"

mkdir -p $PREFIX/bin

sed -i.bak 's|-g -O2 $(CFLAGS0)|-g -O3 $(CFLAGS0) -Xlinker -Wno-implicit-int -Wno-implicit-function-declaration|' Makefile
rm -rf *.bak

make CC="${CC}" -j"${CPU_COUNT}"
# copy binary to prefix folder
install -v -m 0755 bin/domclust Script/*.pl build_input/*.pl "${PREFIX}/bin"

# test
bin/domclust -h
bin/domclust tst/test.hom tst/test.gene
