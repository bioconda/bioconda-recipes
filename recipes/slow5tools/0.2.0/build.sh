#!/bin/bash
./configure
make  CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -D__STDC_FORMAT_MACROS"
mkdir -p $PREFIX/bin
cp slow5tools $PREFIX/bin/slow5tools
