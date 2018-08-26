#!/bin/bash

# comment out random seed function srand() on line 454 for reproducibility
sed -i.bak '454 s|^| //|' $PREFIX/bin/genclustlb.c

make
mkdir -p $PREFIX/bin
cp genclust $PREFIX/bin
