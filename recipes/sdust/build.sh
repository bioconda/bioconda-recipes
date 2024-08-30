#!/bin/bash

set -x -e

mkdir -p "${PREFIX}/bin"

make -j ${CPU_COUNT} CC="$CC" CFLAGS="${CFLAGS} -I${PREFIX}/include -L${PREFIX}/lib"

chmod 0755 sdust

cp -rf sdust "${PREFIX}/bin"
