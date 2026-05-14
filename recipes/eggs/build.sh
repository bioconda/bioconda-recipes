#!/bin/bash

mkdir -p "$PREFIX/bin"

echo "BUILD SCRIPT IS RUNNING"
make CC="${CC}" CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -c -Wall -I lib" LFLAGS="${LDFLAGS} -L${PREFIX}/lib -o"

install -v -m 0755 bin/eggs "$PREFIX/bin"
