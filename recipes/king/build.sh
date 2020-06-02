#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib

g++ -lm -lz -O2 -fopenmp -o king *.cpp
cp king $PREFIX/bin/king
