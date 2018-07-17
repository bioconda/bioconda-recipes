#!/bin/bash

export CXXFLAGS="${CXXFLAGS} -std=c++11"
export LD_LIBRARY_PATH="${PREFIX}/lib"
make all PREFIX=${PREFIX}
