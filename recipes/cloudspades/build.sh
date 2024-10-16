#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include"

cd assembler
PREFIX="${PREFIX}" bash spades_compile.sh -rj2 -DSPADES_ENABLE_PROJECTS="all"
