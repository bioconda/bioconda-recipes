#!/bin/bash
set -eux -o pipefail

# make compilation not be dependent on locale settings
export LC_ALL=C

# build cobs
mkdir -p build
cd build
cmake -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" ..
make -j1

# test
make test

# install
make install
