#!/bin/sh

export CFLAGS="-I$PREFIX/include"
export LDFLAGS="-L$PREFIX/lib"
export CPATH=${PREFIX}/include

make prefix=$PREFIX CXX=$CXX CC=$CC LDFLAGS="-L$PREFIX/lib"
mkdir -p ${PREFIX}/bin
mv bin/* ${PREFIX}/bin/
