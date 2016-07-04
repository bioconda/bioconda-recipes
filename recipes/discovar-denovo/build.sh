#!/bin/sh
set -x -e

#export CC=${PREFIX}/bin/gcc
#export CXX=${PREFIX}/bin/g++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

./configure --prefix=$PREFIX
sed -i 's/CPPFLAGS =/#CPPFLAGS =/' Makefile
make
make install
