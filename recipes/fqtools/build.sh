#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

make CC="$CC -fcommon" LIBS="-L$PREFIX/lib -lhts -lz -lm"
mkdir -p $PREFIX/bin
cp bin/fqtools $PREFIX/bin
