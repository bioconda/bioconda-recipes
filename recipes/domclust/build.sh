#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak 's|-g -O2 $(CFLAGS0)|-g -O3 $(CFLAGS0) -Xlinker -zmuldefs -Wno-implicit-int -Wno-implicit-function-declaration|' Makefile
sed -i.bak 's|-O2|-O3|' Makefile
rm -rf *.bak

make CC="${CC}" -j"${CPU_COUNT}"
# copy binary to prefix folder
install -v -m 0755 bin/domclust Script/*.pl build_input/*.pl "${PREFIX}/bin"

# test
bin/domclust -h
bin/domclust tst/test.hom tst/test.gene
