#!/bin/bash

set -x -e

export INCLUDE_PATH="${BUILD_PREFIX}/include"
export LIBRARY_PATH="${BUILD_PREFIX}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${BUILD_PREFIX}/lib"

export LDFLAGS="-L${BUILD_PREFIX}/lib"
export CPPFLAGS="-I${BUILD_PREFIX}/include"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/scripts

cp -v lib/* $PREFIX/include
cp -v scripts/* $PREFIX/bin

python3 -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
