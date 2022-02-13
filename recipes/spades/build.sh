#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

# Fails on OSX
#bash spades_compile.sh -j 4
BUILD_DIR=build_spades
BASEDIR="$(normalize_path "$(pwd)"/"$(dirname "$0")")"
WORK_DIR="$BASEDIR/$BUILD_DIR"
mkdir -p "$WORK_DIR"

cd "$WORK_DIR"
cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DSPADES_BUILD_INTERNAL=OFF "$BASEDIR/src"
make -j 4
make install
