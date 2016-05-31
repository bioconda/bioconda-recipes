#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

make
mv megahit $PREFIX/bin
mv megahit_asm_core $PREFIX/bin
mv megahit_sdbg_build $PREFIX/bin
mv megahit_toolkit $PREFIX/bin
