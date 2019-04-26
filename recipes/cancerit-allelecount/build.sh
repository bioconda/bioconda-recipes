#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
#export HTSLIB_VERSION=1.7
#wget --ca-certificate=$PREFIX/ssl/cert.pem -O htslib-${HTSLIB_VERSION}.tar.bz2 https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2
#tar -xjvpf htslib-${HTSLIB_VERSION}.tar.bz2
#cd htslib-${HTSLIB_VERSION}
#patch -p0 < $SRC_DIR/patches/htslibcramindex.diff
#make
#cd ../c
cd $SRC_DIR/c
mkdir bin
make OPTINC=-I$C_INCLUDE_PATH HTSLOC=$C_INCLUDE_PATH
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
