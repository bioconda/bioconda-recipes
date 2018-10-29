#!/bin/bash
set -x

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export C_INCLUDE_PATH=${PREFIX}/include

cd htslib
autoheader
autoconf
./configure --enable-s3 --disable-lzma --disable-bz2
make
cd ..

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
