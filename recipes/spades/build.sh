#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH=${PREFIX}/lib
export C_INCLUDE_PATH=${PREFIX}/include
export CPP_INCLUDE_PATH=${PREFIX}/include
export CFLAGS="${CFLAGS} -fcommon"
export CXXFLAGS="${CFLAGS} -fcommon"

bash spades_compile.sh -rj4
