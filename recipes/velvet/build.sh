#!/bin/bash

make 'CATEGORIES=4' 'MAXKMERLENGTH=191' 'OPENMP=1' 'LONGSEQUENCES=1' 'BUNDLEDZLIB=1'
mkdir -p $PREFIX/bin
cp velvetg velveth $PREFIX/bin
