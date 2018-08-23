#!/bin/bash

mkdir -p "$PREFIX/bin"

make

cp wtdmo wtdbg-cns ttr_finder map2dbgcns  *.pl *.sh $PREFIX/bin 
cp wtdbg-1.2.8 $PREFIX/bin/wtdbg
cp kbm-1.2.8  $PREFIX/bin/kbm
