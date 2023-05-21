#!/bin/bash

make -f Makefile.PTHREADS.gcc CC="${CC}"
make -f Makefile.gcc CC="${CC}"

make -f Makefile.SSE3.gcc CC="${CC}"
make -f Makefile.SSE3.PTHREADS.gcc CC="${CC}"

mkdir -p $PREFIX/bin

cp raxmlHPC-PTHREADS $PREFIX/bin
cp raxmlHPC $PREFIX/bin
cp raxmlHPC-PTHREADS-SSE3 $PREFIX/bin
cp raxmlHPC-SSE3 $PREFIX/bin

