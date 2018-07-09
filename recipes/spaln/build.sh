#!/bin/sh
sed -i.bak '1 s|^.*$|#!/usr/bin/env perl|g' seqdb/*.pl
rm -f seqdb/*.bak
# fix small buffer size to handle longer pathnames during conda build (https://github.com/ogotoh/spaln/pull/2)
sed -i.bak 's/^#define MAXL[[:space:]].*/#define MAXL 2056/' src/adddef.h
rm -f src/adddef.h.bak

mkdir -p $PREFIX/man/man1
cp sortgrcd.1 spaln.1 $PREFIX/man/man1

cd src
./configure --exec_prefix=$PREFIX/bin --table_dir=$PREFIX/share/spaln/table --alndbs_dir=$PREFIX/share/spaln/seqdb

make
make install
