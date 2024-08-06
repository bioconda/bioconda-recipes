#!/bin/bash

set -xeuo

# clear out pre-built objects and executables
cd src
make CC="${CC}" CFLAGS="${CFLAGS} -fPIE" -j "${CPU_COUNT}" clobber

make CC="${CC}" CFLAGS="${CFLAGS} -fPIE" LDFLAGS="${LDFLAGS} -L${PREFIX}/lib" all

make install TOP="${PREFIX}/bin"
