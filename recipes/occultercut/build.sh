#!/bin/bash
set -eu -o pipefail
#
# CONDA build script variables
#
# $PREFIX The install prefix
#

mkdir -p "${PREFIX}/bin"

export CPLUS_INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CC="${GXX} ${LDFLAGS}" CFLAGS="${CFLAGS}"

cp OcculterCut "${PREFIX}/bin"
