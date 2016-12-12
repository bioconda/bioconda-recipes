#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

make 
mv fermi2  $PREFIX/bin
mv fermi2.pl  $PREFIX/bin

