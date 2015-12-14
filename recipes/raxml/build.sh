#!/bin/bash

make -f Makefile.PTHREADS.gcc
mkdir -p $PREFIX/bin
cp raxmlHPC-PTHREADS $PREFIX/bin
