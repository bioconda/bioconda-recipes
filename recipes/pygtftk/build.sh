#!/bin/bash
CC=${PREFIX}/bin/gcc
CXX=${PREFIX}/bin/g++
export CPATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
echo $CC
#export CC=/usr/local/bin/gcc
/opt/rh/devtoolset-2/root/usr/bin/gcc -v
#gcc -v

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
