#!/usr/bin/env bash

autoreconf -i
./configure --prefix=${PREFIX} CFLAGS="-I$PREFIX/include" LDFLAGS="-L$PREFIX/lib" 
make -j${CPU_COUNT}
make install

