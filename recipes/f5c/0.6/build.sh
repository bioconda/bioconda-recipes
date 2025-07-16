#!/bin/bash
scripts/install-hts.sh
./configure
make CC=$CC CXX=$CXX CFLAGS="-g -Wall -O2 -std=c++11 -D__STDC_FORMAT_MACROS"
mkdir -p $PREFIX/bin
cp f5c $PREFIX/bin/f5c
