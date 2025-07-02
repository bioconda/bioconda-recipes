#!/bin/bash

mkdir -p $PREFIX/bin

sed -i.bak '8c\CFLAGS=-g -O2 $(CFLAGS0) -Xlinker -zmuldefs' Makefile

make -j"${CPU_COUNT}"
# copy binary to prefix folder
install -v -m 0755 bin/domclust Script/*.pl build_input/*.pl "${PREFIX}/bin"

# test
bin/domclust -h
bin/domclust tst/test.hom tst/test.gene
