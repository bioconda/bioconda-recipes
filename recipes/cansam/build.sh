#!/bin/bash

export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make
cp sam* $PREFIX/bin && \
cp libcansam.a $PREFIX/lib
cp -a cansam $PREFIX/include
