#!/bin/bash

set -x -e

export INCLUDE_PATH="${BUILD_PREFIX}/include:${PWD}/third-party/seqan/core/include"
export LIBRARY_PATH="${BUILD_PREFIX}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PWD}/lib"

export LDFLAGS="-L${BUILD_PREFIX}/lib -L${PWD}/third-party/seqan/core/include"
export CCPFLAGS="-I${BUILD_PREFIX}/include -I${PWD}/third-party/seqan/core/include"

mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/scripts

cp -v lib/* $PREFIX/include
cp -v scripts/* $PREFIX/bin
#cp -vr third-party/seqan/core/include $PREFIX/include/seqan

python3 -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv
