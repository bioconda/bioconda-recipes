#!/bin/bash

set -x -e

mkdir -p "${PREFIX}/bin"
ls -la $PREFIX/lib

ls -la $PREFIX/include
make CC="$CC" INCLUDES="-I${PREFIX}/include -L${PREFIX}/lib" -j ${CPU_COUNT}

chmod 0755 sdust

cp -rf sdust "${PREFIX}/bin"
