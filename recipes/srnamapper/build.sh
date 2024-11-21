#!/bin/bash

set -xe

# zlib hack
make -j ${CPU_COUNT} CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS+="-g -Wall -O2 -L$PREFIX/lib"
chmod +x srnaMapper
mkdir -p ${PREFIX}/bin
cp -f srnaMapper ${PREFIX}/bin
