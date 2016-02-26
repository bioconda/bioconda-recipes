#!/bin/bash
#

CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++
perl scripts/dependencies.pl | sed -n -e 's/missing.*//p' | cpanm 
./configure --prefix="$PREFIX"
make AM_CFLAGS='-DNAN="(0.0/0.0)"' && make test && make install

