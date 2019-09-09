#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

mkdir -pv $PREFIX/bin/HR2/bin

g++ HR2.cpp -o $PREFIX/bin/HR2/bin/HR2.exe
chmod a+x $PREFIX/bin/HR2/bin/HR2.exe

cp $PREFIX/bin/HR2/bin/HR2.exe ${PREFIX}/bin
