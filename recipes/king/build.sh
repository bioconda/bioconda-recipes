#!/bin/bash

#export CPP_INCLUDE_PATH=${PREFIX}/include
#export CXX_INCLUDE_PATH=${PREFIX}/include
#export CPLUS_INCLUDE_PATH=${PREFIX}/include
#export LIBRARY_PATH=${PREFIX}/lib
#export CXXFLAGS="$CXXFLAGS "

$CXX -lm -DDYNAMIC_ZLIB -O2 -fopenmp -o king *.cpp
cp king $PREFIX/bin/king
