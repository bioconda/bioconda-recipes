#!/bin/bash

git submodule init
git submodule update
make 'CATEGORIES=4' 'MAXKMERLENGTH=191' 'OPENMP=1' 'LONGSEQUENCES=1' 'BUNDLEDZLIB=1' CC="${CC}" CFLAGS="${CFLAGS}" 
mkdir -p $PREFIX/bin
cp oases scripts/oases_pipeline.py $PREFIX/bin
