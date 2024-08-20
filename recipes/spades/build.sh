#!/bin/bash

set -e -o pipefail -x

export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export CFLAGS="${CFLAGS} -O3 -fcommon"
export CXXFLAGS="${CFLAGS} -O3 -fcommon -I${PREFIX}/include"

PREFIX="${PREFIX}" bash spades_compile.sh -rj"${CPU_COUNT}" -DSPADES_USE_NCBISDK=ON -DSPADES_ENABLE_PROJECTS="all"
