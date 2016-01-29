#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -p $PREFIX/bin

make 
cp minidot $PREFIX/bin 
cp miniasm $PREFIX/bin

