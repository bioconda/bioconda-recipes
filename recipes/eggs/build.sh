#!/bin/bash
make CC="${CC}" CFLAGS="-I${PREFIX}/include -c -Wall -I lib" LFLAGS="-L${PREFIX}/lib -o"
mkdir -p "$PREFIX/bin"
cp bin/eggs "$PREFIX/bin"
