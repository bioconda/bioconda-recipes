#!/bin/bash

set -xe

make -j ${CPU_COUNT} CC=${CC} CFLAGS="${CFLAGS}" 'CATEGORIES=4' 'MAXKMERLENGTH=191' 'OPENMP=1' 'LONGSEQUENCES=1'
mkdir -p $PREFIX/bin
cp velvetg velveth $PREFIX/bin
