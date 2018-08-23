#!/bin/bash

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

make -j${CPU_COUNT}
make test
mkdir -p $PREFIX/bin
cp vt $PREFIX/bin
