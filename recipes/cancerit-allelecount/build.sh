#!/bin/bash
set -eu
export LIBRARY_PATH=${PREFIX}/lib
export INCPATH=${PREFIX}/include
#export HTSLIB_VERSION=1.7
#wget --ca-certificate=$PREFIX/ssl/cert.pem -O htslib-${HTSLIB_VERSION}.tar.bz2 https://github.com/samtools/htslib/releases/download/${HTSLIB_VERSION}/htslib-${HTSLIB_VERSION}.tar.bz2
#tar -xjvpf htslib-${HTSLIB_VERSION}.tar.bz2
#cd htslib-${HTSLIB_VERSION}
#patch -p0 < $SRC_DIR/patches/htslibcramindex.diff
#./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
#make install
#cd ../c
cd $SRC_DIR/c
mkdir bin
#Inject CC
sed -i 's/CC = gcc /compiler = ${CC} /g' Makefile
sed -i 's/$(CC) /$(compiler) /g' Makefile
#Force HTSLIb locations
sed -i 's#HTSLOC?=$(HTSLIB)#HTSLOC=${PREFIX}/lib#g' Makefile
sed -i 's#prefix=?/usr/local#prefix=${PREFIX}#g' Makefile
make OPTINC="-I$PREFIX/include -L$PREFIX/lib"
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
