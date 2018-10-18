#!/bin/bash
set -eu

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

if [ "$(uname)" == "Darwin" ]; then
    make EIGEN_INCLUDE_PATH=${PREFIX}/include/eigen3 CXX=clang++
else
    make EIGEN_INCLUDE_PATH=${PREFIX}/include/eigen3
fi

mkdir -p ${PREFIX}/bin
cp bin/gemma ${PREFIX}/bin/gemma
