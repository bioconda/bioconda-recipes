#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

# Fails on OSX
#bash spades_compile.sh -j 4
WORK_DIR="build_spades"
mkdir -p $WORK_DIR

cd "$WORK_DIR"
$BUILD_PREFIX/bin/cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DSPADES_BUILD_INTERNAL=OFF ../src
make -j 4
make install
