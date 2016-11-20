#!/bin/bash

#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++


make 
mkdir -p $PREFIX/bin
cp verifyBamID/bin/verifyBamID $PREFIX/bin

