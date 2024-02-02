#!/bin/bash
set -eu -o pipefail
#
# CONDA build script variables
#
# $PREFIX The install prefix
#

mkdir -p "${PREFIX}/bin"

export INCLUDE_PATH="${PREFIX}/include"
export LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

make CFLAGS="${CFLAGS} -I${PREFIX}/include" LDFLAGS="${LDFLAGS}"

cp OcculterCut "${PREFIX}/bin"
