#!/bin/bash

make CC="$CC" LIBDIR="-L$PREFIX/lib" INCLUDE="-I$PREFIX/include" -j"${CPU_COUNT}"
mkdir -p $PREFIX/bin
mv pTrimmer-* $PREFIX/bin/ptrimmer
