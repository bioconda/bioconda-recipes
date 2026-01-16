#!/bin/bash

set -xe

export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# zlib hack
make CC="${CC}" INCLUDES="-I${PREFIX}/include" CFLAGS+="-g -Wall -O3 -L${PREFIX}/lib" -j"${CPU_COUNT}"
mkdir -p ${PREFIX}/bin
install -v -m 0755 srnaMapper "${PREFIX}/bin"
