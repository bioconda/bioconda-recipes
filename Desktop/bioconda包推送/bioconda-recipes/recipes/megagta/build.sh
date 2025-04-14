#!/bin/bash
#strictly use anaconda build environment
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++
export CPATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include

sh make.sh
mkdir -p $PREFIX/bin
cp bin/* $PREFIX/bin
chmod +x $PREFIX/bin/megagta.py
