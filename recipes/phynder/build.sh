#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive

autoconf
./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make install

cd ../

sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile

make
make install
