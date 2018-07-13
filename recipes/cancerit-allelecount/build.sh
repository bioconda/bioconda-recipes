#!/bin/bash
set -eu

wget --ca-certificate=$PREFIX/ssl/cert.pem -O htslib-1.2.1.tar.bz2 https://github.com/samtools/htslib/releases/download/1.2.1/htslib-1.2.1.tar.bz2
tar -xjvpf htslib-1.2.1.tar.bz2
cd htslib-1.2.1
patch -p0 < $SRC_DIR/patches/htslibcramindex.diff
make
cd ../c
mkdir bin
make OPTINC=-I$SRC_DIR/htslib-1.2.1 HTSLOC=$SRC_DIR/htslib-1.2.1
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
