#!/bin/bash
set -eu

mkdir -p $PREFIX/bin
LDFLAGS="-L$PREFIX/lib"
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib

#autoreconf -i -f
#./configure --with-libmaus2=${PREFIX}/lib	--prefix=${PREFIX}/bin/
./configure --prefix=${PREFIX}/bin/
make install
