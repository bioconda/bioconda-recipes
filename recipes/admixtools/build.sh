#!/bin/bash

# clear out pre-built objects and executables
cd src
make CC="${CC}" clobber -j"${CPU_COUNT}"

make CC="${CC}" CFLAGS="$CFLAGS -O3 -fPIC -I${PREFIX}/include" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" all -j"${CPU_COUNT}"

make install TOP="${PREFIX}/bin"
