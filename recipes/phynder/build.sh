#!/bin/bash
set -x
set +e

export CFLAGS="$CFLAGS -I$PREFIX/include"
export LDFLAGS="$LDFLAGS -L$PREFIX/lib"

git clone https://github.com/samtools/htslib.git
cd htslib
git submodule update --init --recursive

## from https://github.com/pachterlab/kallisto/issues/303#issuecomment-884612169
sed '/AC_PROG_CC/a \
AC_CANONICAL_HOST \
AC_PROG_INSTALL \
' configure.ac >configure.ac2
mv configure.ac2 configure.ac
autoreconf -i
autoheader
autoconf

./configure --prefix=${PREFIX} --enable-libcurl --with-libdeflate --enable-plugins --enable-gcs --enable-s3
make CC=$CC install

cd ../

sed -i 's#HTSDIR=../htslib#HTSDIR=./htslib#g' Makefile

make
make install
