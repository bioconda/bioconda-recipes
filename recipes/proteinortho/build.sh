#!/bin/bash

# echo "build start"

export C_INCLUDE_PATH="${PREFIX}/include"
export CPP_INCLUDE_PATH="${PREFIX}/include"
export CXX_INCLUDE_PATH="${PREFIX}/include"
export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"

#ln -s $BUILD_PREFIX/bin/x86_64-conda_cos6-linux-gnu-g++ g++
# #ln -s $GCC gcc
#export PATH=$PWD:$PATH
# export PATH=$PREFIX:$PATH
# export PATH=$PREFIX/bin:$PATH
# ls -las $LIBRARY_PATH
# echo $PATH

make clean
make all -j${CPU_COUNT}
mkdir -p $PREFIX/bin
make install PREFIX=$PREFIX/bin/