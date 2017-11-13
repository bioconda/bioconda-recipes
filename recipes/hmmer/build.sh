#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

# Fix broken configure option
sed -i.bak -e 's/acx_maxopt_portable=$withval/acx_maxopt_portable=$enableval/' configure
# --enable-portable-binary should be removed for the next HMMER release where this should be unnecessary
./configure --enable-portable-binary --prefix=$PREFIX
make -j4
make install
