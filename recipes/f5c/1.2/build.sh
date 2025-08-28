#!/bin/bash
scripts/install-hts.sh
scripts/install-zstd.sh
./configure  --enable-localzstd
cd slow5lib
make CC=$CC CXX=$CXX
cd ..
export CFLAGS="${CFLAGS} -D__STDC_FORMAT_MACROS"
make  CC=$CC CXX=$CXX
mkdir -p $PREFIX/bin
cp f5c $PREFIX/bin/f5c
