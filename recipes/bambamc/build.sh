#!/usr/bin/env bash

set -xe

# use newer config.guess and config.sub that support osx arm64
cp ${RECIPE_DIR}/config.* .

export C_INCLUDE_PATH=${PREFIX}/include
export LIBRARY_PATH=${PREFIX}/lib
./configure --prefix=${PREFIX}
make -j ${CPU_COUNT}
make install
