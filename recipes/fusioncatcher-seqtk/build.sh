#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CC="${CC}" CFLAGS="${CFLAGS}"
cp seqtk $PREFIX/bin/
