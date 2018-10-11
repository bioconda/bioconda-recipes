#!/bin/bash
#CC=${PREFIX}/bin/gcc
#CXX=${PREFIX}/bin/g++
#export CPATH=${PREFIX}/include
#export CPP_INCLUDE_PATH=${PREFIX}/include
#export C_INCLUDE_PATH=${PREFIX}/include
##echo $CC
##export CC=/usr/local/bin/gcc
##/opt/rh/devtoolset-2/root/usr/bin/gcc -v
##gcc -v
#
#
#
#echo "${PREFIX}/bin/gcc -v"
#${PREFIX}/bin/gcc -v
#
#echo "gcc -v"
#gcc -v
#
#echo "/opt/rh/devtoolset-2/root/usr/bin/gcc -v"
#/opt/rh/devtoolset-2/root/usr/bin/gcc -v

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
