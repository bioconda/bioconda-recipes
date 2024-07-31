#!/usr/bin/env bash

set -xe

mkdir -p ${PREFIX}/bin

export LIBRARY_PATH=${PREFIX}/lib
export LD_LIBRARY_PATH=${PREFIX}/lib
export CPATH=${PREFIX}/include
export C_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export PATH=$PATH:${PREFIX}/bin

mkdir -p ${PREFIX}/bin
ln -fs $CC ${PREFIX}/bin/gcc
ln -fs $CXX ${PREFIX}/bin/g++

make -j ${CPU_COUNT} -C src

cp -r bin/* ${PREFIX}/bin/
cp -r script/* ${PREFIX}/bin/
chmod +x ${PREFIX}/bin/pipeline.py

unlink ${PREFIX}/bin/gcc
unlink ${PREFIX}/bin/g++
