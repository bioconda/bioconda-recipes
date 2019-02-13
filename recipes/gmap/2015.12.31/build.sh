#!/bin/sh

export C_INCLUDE_PATH=${PREFIX}/include
export LD_LIBRARY_PATH=${PREFIX}/lib
export LDFLAGS="-L${PREFIX}/lib"

env MAX_READLENGTH=500 ./configure --prefix=${PREFIX} --enable-avx2=no
make -j 2
make install prefix=${PREFIX}
