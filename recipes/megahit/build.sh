#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

make
mv megahit $PREFIX
mv megahit_asm_core $PREFIX 
mv megahit_sdbg_build $PREFIX
mv megahit_toolkit $PREFIX
