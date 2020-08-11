#!/bin/bash
scripts/install-hts.sh
./configure
make CC=$CC CXX=$CXX -D__STDC_FORMAT_MACROS=1
mkdir -p $PREFIX/bin
cp f5c $PREFIX/bin/f5c
