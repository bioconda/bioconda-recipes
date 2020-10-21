#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib

if [ "`uname`" == "Darwin" ]; then
    make CC=${CC} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
else
    make CC=${CC} htslib_include_dir=${PREFIX}/include htslib_lib_dir=${PREFIX}/lib
fi

mkdir -p ${PREFIX}/bin
cp -f cellsnp-lite ${PREFIX}/bin

