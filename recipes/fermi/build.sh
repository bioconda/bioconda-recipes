#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

make 
mv fermi  $PREFIX/bin
mv run-fermi.pl $PREFIX/bin
