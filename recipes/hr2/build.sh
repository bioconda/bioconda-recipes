#!/bin/sh

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++

g++ HR2.cpp -o HR2.exe
chmod a+x ./HR2.exe