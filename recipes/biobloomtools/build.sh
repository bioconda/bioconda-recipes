#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

# This script was taken from https://github.com/jlanga/exfi

git clone --recursive https://github.com/bcgsc/biobloom.git
cd biobloom/
git submodule update --init
git checkout 0a42916922d42611a087d4df871e424a8907896e
./autogen.sh
./configure --prefix=${PREFIX}
make -j 4
make install
