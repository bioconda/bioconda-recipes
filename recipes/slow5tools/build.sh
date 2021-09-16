#!/bin/bash
scripts/install-zstd.sh
./configure  --enable-localzstd
export CFLAGS="${CFLAGS} -D__STDC_FORMAT_MACROS"
make  CC=$CC CXX=$CXX 
mkdir -p $PREFIX/bin
cp slow5tools $PREFIX/bin/slow5tools
