#!/bin/sh

export CPATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

make -j $CPU_COUNT

make test

mv megahit $PREFIX/bin
mv megahit_asm_core $PREFIX/bin
mv megahit_sdbg_build $PREFIX/bin
mv megahit_toolkit $PREFIX/bin

mkdir -p $PREFIX/share/megahit
mv example $PREFIX/share/megahit
