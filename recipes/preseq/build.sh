#!/bin/bash

export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CXX_INCLUDE_PATH=${PREFIX}/include
export CPLUS_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
if [ "$(uname)" == "Darwin" ]; then
    CXXFLAGS="-stdlib=libstdc++"
fi
make CXX=$CXX LIBS="-L$PREFIX/lib -lgsl -lgslcblas -lz" install ROOT="."
