#!/bin/bash
#

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++
./configure --prefix="$PREFIX"
make AM_CFLAGS='-DNAN="(0.0/0.0)"' && make test && make install

