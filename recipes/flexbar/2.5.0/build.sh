#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
cmake .
make

mkdir -p ${PREFIX}/bin
cp flexbar ${PREFIX}/bin
mkdir -p ${PREFIX}/share/doc/flexbar
cp *.md ${PREFIX}/share/doc/flexbar
