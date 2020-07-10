#!/usr/bin/env bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
make CPP="${CXX}" CPPFLAGS="${CXXFLAGS}"
mkdir -p $PREFIX/bin
cp MuSE $PREFIX/bin/
