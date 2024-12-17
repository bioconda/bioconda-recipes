#!/bin/bash

# fail on all errors
set -e

export INCLUDES="-I${PREFIX}/include"
export LIBPATH="-L${PREFIX}/lib"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

mkdir -p "${PREFIX}/bin"

cd src
make CC="${CC}" CXX="${CXX} -O3 -I${PREFIX}/include" -j"${CPU_COUNT}"

install -v -m 0755 ${SRC_DIR}/build/bin/canu "${PREFIX}/bin"
