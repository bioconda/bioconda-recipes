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
# Produce this error:
# Error: bin/gcc is a symlink to a path that may not exist after the build is completed (/opt/conda/conda-bld/pygtftk_1539270111754/_build_env/bin/x86_64-conda_cos6-linux-gnu-cc) compiling .pyc files...
#ln -s $CC $PREFIX/bin/gcc
ln -s $CC `dirname $CC`/gcc
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

cp bin/* $PREFIX/bin/
