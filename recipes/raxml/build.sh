#!/bin/bash

make -f Makefile.PTHREADS.gcc
make -f Makefile.gcc
mkdir -p $PREFIX/bin
cp raxmlHPC-PTHREADS $PREFIX/bin
cp raxmlHPC $PREFIX/bin
