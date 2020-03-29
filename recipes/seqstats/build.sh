#!/bin/sh
sed -i.bak -e "s#gcc#$CC#" Makefile
make
mkdir -p $PREFIX/bin
cp seqstats $PREFIX/bin
