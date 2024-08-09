#!/bin/bash

set -x -e

# export variables for compiling
export INCLUDE_PATH="${BUILD_PREFIX}/include:${PWD}/third-party/seqan/core/include"
export LIBRARY_PATH="${BUILD_PREFIX}/lib"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${PWD}/lib"

export LDFLAGS="-L${BUILD_PREFIX}/lib -L${PWD}/third-party/seqan/core/include"
export CCPFLAGS="-I${BUILD_PREFIX}/include -I${PWD}/third-party/seqan/core/include"

# create directories for compiling
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/include
mkdir -p $PREFIX/lib
mkdir -p $PREFIX/scripts

# populate compiling directories
cp -v lib/* $PREFIX/include
cp -v scripts/* $PREFIX/bin

# copies over third-party/seqan/core/include/seqan
mkdir -pv $PREFIX/include/seqan
cp -vr third-party/seqan/core/include/seqan/* $PREFIX/include/seqan/

# install khmer
$PYTHON -m pip install . --no-deps --no-build-isolation --no-cache-dir --use-pep517 -vvv

# debugging line to find where khmer was installed
echo "here i am! ⊂◉‿◉つ "
ls -lhR
