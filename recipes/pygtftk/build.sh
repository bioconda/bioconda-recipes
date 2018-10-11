#!/bin/bash
#CC=${PREFIX}/bin/gcc
#CXX=${PREFIX}/bin/g++
#export CPATH=${PREFIX}/include
#export CPP_INCLUDE_PATH=${PREFIX}/include
#export C_INCLUDE_PATH=${PREFIX}/include
echo "CC: $CC"
echo "PATH: $PATH"
echo "PREFIX: $PREFIX"
##export CC=/usr/local/bin/gcc
##/opt/rh/devtoolset-2/root/usr/bin/gcc -v
##gcc -v
#export CC='/opt/rh/devtoolset-2/root/usr/bin/gcc'
#export PATH='/opt/rh/devtoolset-2/root/usr/bin:$PATH'
#
#export C_INCLUDE_PATH=$PREFIX/include
#export CPP_INCLUDE_PATH=$PREFIX/include
#export CPATH=${PREFIX}/include
#
#
ln -s $CC $PREFIX/bin/gcc
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
