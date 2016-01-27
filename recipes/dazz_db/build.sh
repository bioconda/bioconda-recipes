#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++


mkdir -p $PREFIX/bin
make
cp $(find . -maxdepth 1 -type f -perm /u=x)  $PREFIX/bin

