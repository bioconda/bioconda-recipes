#!/bin/bash

set -x -e

export CC=${PREFIX}/bin/cc
export CXX=${PREFIX}/bin/c++

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure --disable-debug --prefix="$PREFIX"
make
make install
