#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

./configure
make

#cflags="-g -Wall -O2 -Wno-unused-function -fgnu89-inline -I${PREFIX}/include"

#if [ "`uname`" == "Darwin" ]; then
#    make CC=${CC} CFLAGS="-fgnu89-inline -fcommon ${CFLAGS}" LDFLAGS="${LDFLAGS}"
#else
#    make CC=${CC} CFLAGS="${cflags}" htslib_lib_dir=${PREFIX}/lib
#fi

mkdir -p ${PREFIX}/bin
cp -f cellsnp-lite ${PREFIX}/bin

