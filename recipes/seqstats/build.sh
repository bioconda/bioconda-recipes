#!/bin/sh
sed -i.bak -e "s#gcc#$CC $CFLAGS $LDFLAGS#" Makefile
make
mkdir -p $PREFIX/bin
cp seqstats $PREFIX/bin
