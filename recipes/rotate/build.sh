#!/bin/bash
set -xe
make -j"${CPU_COUNT}" CC=$CC INCLUDES="-I$PREFIX/include" CFLAGS+="-g -Wall -O2 -L$PREFIX/lib"
chmod +x rotate
chmod +x composition
mkdir -p ${PREFIX}/bin
cp -f rotate composition ${PREFIX}/bin
