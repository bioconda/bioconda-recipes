#!/bin/bash

set -x -e

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

export LDFLAGS="-L${PREFIX}/lib"
export CXXFLAGS="-I$PREFIX/include"
export CPPFLAGS="-I${PREFIX}/include"
export LC_ALL=C

make

cp KmerStream $PREFIX/bin
cp KmerStreamEstimate.py $PREFIX/bin
cp KmerStreamJoin $PREFIX/bin
