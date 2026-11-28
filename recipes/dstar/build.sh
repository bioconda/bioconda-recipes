#!/bin/bash

mkdir -p "$PREFIX/bin"

mkdir -p "${PREFIX}/share/dstar/example"
cp -r example/* "${PREFIX}/share/dstar/example/"

make CC="${CC}" CFLAGS="${CFLAGS} -O3 -I${PREFIX}/include -c -Wall -I lib" LFLAGS="${LDFLAGS} -L${PREFIX}/lib -o"

install -v -m 0755 bin/dstar "$PREFIX/bin"
