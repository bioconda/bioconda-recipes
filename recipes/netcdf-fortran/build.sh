#!/bin/bash

export CPPFLAGS="-I${PREFIX}/include $CPPFLAGS"
export CFLAGS="-I${PREFIX}/include $CFLAGS"
export LDFLAGS="-L${PREFIX}/lib $LDFLAGS"
export DYLD_LIBRARY_PATH=${PREFIX}/lib
./configure --prefix=$PREFIX --enable-netcdf4

make
#make check
make install
