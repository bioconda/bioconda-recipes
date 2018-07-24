#!/bin/bash

export LIBRARY_PATH=${PREFIX}/lib
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
make
mkdir -p ${PREFIX}/bin
mv skesa ${PREFIX}/bin/
