#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CC=${CC} CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" all
mkdir -p $PREFIX/bin
cp -f seqtk $PREFIX/bin/
