#!/usr/bin/env bash

set -xe
export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
