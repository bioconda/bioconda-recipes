#!/bin/bash

make -f Makefile.PTHREADS.gcc
make -f Makefile.gcc

make -f Makefile.SSE3.gcc
make -f Makefile.SSE3.PTHREADS.gcc

make -f Makefile.AVX2.gcc
make -f Makefile.AVX2.PTHREADS.gcc

mkdir -p $PREFIX/bin

cp raxmlHPC-PTHREADS $PREFIX/bin
cp raxmlHPC $PREFIX/bin
cp raxmlHPC-PTHREADS-SSE3 $PREFIX/bin
cp raxmlHPC-SSE3 $PREFIX/bin
cp raxmlHPC-PTHREADS-AVX2 $PREFIX/bin
cp raxmlHPC-AVX2 $PREFIX/bin

