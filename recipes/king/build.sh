#!/bin/bash

export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

${CXX} -I${CXX_INCLUDE_PATH} -L${LIBRARY_PATH} -lm -lz -O2 -fopenmp -o king *.cpp
mkdir -p $PREFIX/bin
cp ./king $PREFIX/bin/king
