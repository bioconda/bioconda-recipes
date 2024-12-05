#!/bin/bash -euo

# clear out pre-built objects and executables
cd src
make CC="${CC}" -j "${CPU_COUNT}" clobber

make CC="${CC}" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" all

make install TOP="${PREFIX}/bin"
