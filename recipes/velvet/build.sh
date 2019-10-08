#!/bin/bash

make CC=${CC} CFLAGS="${CFLAGS}" 'CATEGORIES=4' 'MAXKMERLENGTH=191' 'OPENMP=1' 'LONGSEQUENCES=1'
mkdir -p $PREFIX/bin
cp velvetg velveth $PREFIX/bin
