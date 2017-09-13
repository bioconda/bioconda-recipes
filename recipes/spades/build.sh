#!/bin/bash

set -e -o pipefail

mkdir -p $PREFIX/bin
mkdir build
pushd build

cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" ../src
make 
make install
popd
