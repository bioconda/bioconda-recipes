#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -fcommon -Wno-deprecated-declarations -Wno-unused-variable -Wno-parentheses -Wno-unused-result -Wno-unused-but-set-variable -Wno-conversion"

PREFIX="${PREFIX}" ./spades_compile.sh -rj"${CPU_COUNT}"
